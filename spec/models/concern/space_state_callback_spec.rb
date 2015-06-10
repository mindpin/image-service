require 'rails_helper'

describe SpaceStateCallback do
  context 'field  qiniu_image_space_size   av_space_size' do
    before{
      @user = User.create
    }

    describe "@user upload a qiniu image" do
      before{
        @filesize = 219350
        @image = FileEntity.create!(
          original: "paste-1431337971644.png", 
          token: "FlsElzV4", 
          mime: "image/png", 
          kind: "image",
          meta: {
            "major_color" => {
              "rgba" => "rgba(164,166,168,1)", 
              "hex"  => "#A4A6A8"
            }, 
            "height"   => 2001, 
            "width"    => 1125, 
            "filesize" => @filesize
          },
          user: @user
        )
      }

      it{
        @user.qiniu_image_space_size.should == @filesize
      }

      it{
        @user.av_space_size.should == 0
      }

      it{
        @image.destroy
        @user.qiniu_image_space_size.should == 0
      }

      it{
        @image.destroy
        @user.av_space_size.should == 0
      }

      describe "@user upload a oss image" do
        before{
          @filesize = 219350
          @image = FileEntity.create!(
            original: "paste-1431337971644.png", 
            token: "FlsElzV4", 
            mime: "image/png", 
            kind: "image",
            meta: {
              "major_color" => {
                "rgba" => "rgba(164,166,168,1)", 
                "hex"  => "#A4A6A8"
              }, 
              "height"   => 2001, 
              "width"    => 1125, 
              "filesize" => @filesize
            },
            is_oss: true,
            user: @user
          )
        }

        it{
          @user.qiniu_image_space_size.should == @filesize
        }

        it{
          @image.destroy
          @user.qiniu_image_space_size.should == @filesize
        }

        it{
          @user.av_space_size.should == 0
        }

        it{
          @image.destroy
          @user.av_space_size.should == 0
        }

        describe "@user upload a audio" do
          before{
            @audio_size = 7333704
            @audio = FileEntity.create!(
              original: "PS 射雕英雄传.mp3", 
              token: "ftGcjyyF", 
              mime: "audio/mpeg", 
              kind: "audio",
              meta: {
                "avinfo"=>{
                  "total_bit_rate"=>"320000", 
                  "total_duration"=>"183.342600", 
                  "audio_codec_name"=>"mp3", 
                  "audio_bit_rate"=>"320000", 
                  "audio_duration"=>"183.342600"
                }, 
                "filesize"=>"7333704"
              },
              user: @user
            )
          }

          it{
            @user.qiniu_image_space_size.should == @filesize
          }

          it{
            @audio.destroy
            @user.qiniu_image_space_size.should == @filesize
          }

          it{
            @user.av_space_size.should == @audio_size
          }

          it{
            @audio.destroy
            @user.av_space_size.should == 0
          }

          describe "@user upload a video" do
            before{
              @video_size = 7241236
              @video = FileEntity.create!(
                original: "01.mp4", 
                token: "ZDBDeYoG", 
                mime: "video/mp4", 
                kind: "video",
                meta: {
                  "avinfo"=>{
                    "format"=>"mov,mp4,m4a,3gp,3g2,mj2", 
                    "total_bit_rate"=>"491264", 
                    "total_duration"=>"117.920000", 
                    "video_codec_name"=>"h264", 
                    "video_bit_rate"=>"423273", 
                    "video_duration"=>"117.920000", 
                    "height"=>"432", 
                    "width"=>"576", 
                    "audio_codec_name"=>"aac", 
                    "avinfo_audio_bit_rate"=>"64444", 
                    "avinfo_audio_duration"=>"117.910930"
                  }, 
                  "filesize"=>"7241236"
                },
                user: @user
              )
            }

            it{
              @user.qiniu_image_space_size.should == @filesize
            }

            it{
              @video.destroy
              @user.qiniu_image_space_size.should == @filesize
            }

            it{
              @user.av_space_size.should == (@audio_size + @video_size)
            }

            it{
              @video.destroy
              @user.av_space_size.should == @audio_size
            }
          end
        end
      end
    end
  end

  it "image with @user and string filesize should not be raise" do
    @user = create(:user)
    create(:image_with_str_filesize, user: @user).should be_valid
  end
end
