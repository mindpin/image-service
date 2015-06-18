class TranscodingRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Enumerize

  field :info,                   type: Hash
  field :qiniu_key,              type: String
  field :fops,                    type: String
  field :status,                 type: String
  field :quniu_persistance_id,   type: String

  enumerize :status, in: [:processing, :success, :failure], default: :processing
  belongs_to :file_entity

  def url
    File.join(ENV['QINIU_DOMAIN'], qiniu_key)
  end

  module FileEntityMethods
    def self.included(base)
      base.has_many :transcoding_records
      base.after_create :put_audio_and_video_transcode_to_quene
    end

    def put_audio_and_video_transcode_to_quene
      case self.mime.split("/").first
      when 'audio'
        put_audio_transcode_to_quene
      when 'video'
        put_video_transcode_to_quene
      end
    end

    def put_audio_transcode_to_quene
      bit_rate = self.meta["avinfo"]["total_bit_rate"]
      if bit_rate.to_i >= 128000
        # 转码 128k
        put_audio_transcode_to_quene_by_bit_rate("128k")
      end

      if bit_rate.to_i >= 64000
        # 转码 64k
        put_audio_transcode_to_quene_by_bit_rate("64k")
      end

      if bit_rate.to_i >= 32000
        # 转码 32k
        put_audio_transcode_to_quene_by_bit_rate("32k")
      end
    end

    def put_video_transcode_to_quene
      # 完全按照 http://www.youku.com/help/view/fid/8#q20
      # 的逻辑会很复杂，需要借助一些数据后才能调整
      # 先用简化的逻辑处理
      bit_rate = self.meta["avinfo"]["total_bit_rate"]
      if bit_rate.to_i <= 1000000
        # 转码普清
        put_video_transcode_to_quene_by_bit_rate(bit_rate.to_i-64000,"64k")
      end

      if bit_rate.to_i >= 1000000
        # 转码高清
        put_video_transcode_to_quene_by_bit_rate("1m","128k")
      end

      if bit_rate.to_i >= 1500000
        # 转码超清
        put_video_transcode_to_quene_by_bit_rate("1.5m", "320k")
      end

      if bit_rate.to_i >= 3500000
        # 转码超清
        put_video_transcode_to_quene_by_bit_rate("3.5m", "320k")
      end
    end

    def put_video_transcode_to_quene_by_bit_rate(video_bit_rate, audio_bit_rate)
      fops = "avthumb/mp4/vcodec/libx264/vb/#{video_bit_rate}/acodec/libmp3lame/ab/#{audio_bit_rate}"
      qiniu_key = File.join(key_prefix, "#{video_bit_rate}.mp4")
      put_transcode_to_quene(fops, qiniu_key)
    end

    # bit_rate -> 128K
    def put_audio_transcode_to_quene_by_bit_rate(bit_rate)
      fops = "avthumb/mp3/acodec/libmp3lame/ab/#{bit_rate}"
      qiniu_key = File.join(key_prefix, "#{bit_rate}.mp3")
      put_transcode_to_quene(fops, qiniu_key)
    end

    def put_transcode_to_quene(fops, qiniu_key)
      transcoding_record = self.transcoding_records.create(
        :qiniu_key => qiniu_key,
        :fops      => fops
      )
      AudioAndVideoTranscodeWorker.perform_async(transcoding_record.id.to_s)
    end

  end
end
