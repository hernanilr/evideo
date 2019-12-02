# frozen_string_literal: true

require 'time'

module Evideo
  # permite analizar string output do comando sonda video
  class HRVideo < String
    attr_reader :video, :ext, :base, :duration, :bitrate

    # Duration: 01:01:08.50, start: 0.000000, bitrate: 2228 kb/s
    R1 = /duration:\s+(\d\d:\d\d:\d\d).*bitrate:\s+(\d+)\s+kb/i.freeze
    # Stream #0:0: Video: h264 (Main), yuv420p(tv, bt709, progressive), 1280x720
    # [SAR 1:1 DAR 16:9], 23.98 fps, 23.98 tbr, 1k tbn, 180k tbc (default)
    R2 = /stream.*video:.*x\s*(\d+).*\s+(\d+\.*\d*)\s+fps/i.freeze
    # display_aspect_ratio=16:9
    R3 = /display_aspect_ratio\s*=\s*(\d+:\d+)$/i.freeze

    def initialize(fvideo)
      @video = fvideo
      @ext = File.extname(fvideo)
      @base = File.basename(fvideo, @ext).downcase
      @duration = '00:00:00'
      @bitrate = 0
      @probe = `#{probe}` if File.exist?(fvideo)
      return unless @probe

      r1 = @probe.scan(R1).flatten
      @duration = r1[0]
      @bitrate = r1[1].to_i
    end

    def r2
      return unless @probe

      r2 = @probe.scan(R2).flatten
      @height = r2[0].to_i
      @fps = r2[1].to_f
    end

    def r3
      return unless @probe

      @ratio = @probe.scan(R3).flatten[0]
    end

    def height
      r2 unless @height

      @height
    end

    def fps
      r2 unless @fps

      @fps
    end

    def ratio
      r3 unless @ratio

      @ratio
    end

    def rm_show
      return video unless @probe

      "#{video} duration: #{duration} bitrate: #{bitrate}"
    end

    def vfok?(fout)
      return false unless File.exist?(fout.video)

      # tempo video processado < tempo original -60 segundos ou
      # bitrate video processado > bitrate video origunal
      return false unless Time.parse(fout.duration) >
                          Time.parse(duration) - 60 &&
                          fout.bitrate < 3000

      puts "rm #{video} # #{fout.rm_show}"
      true
    end

    def vdok?(ary, out)
      if ary.empty? then false
      elsif vfok?(HRVideo.new("#{ary[0]}/#{out}/#{base}.mp4")) then true
      else  vdok?(ary.drop(1), out)
      end
    end

    def geral
      # general options
      '-loglevel quiet -hide_banner' +
        # para ignorar segundos no inicio
        # ' -ss 15' \
        ''
    end

    def metadata
      # clean metadata
      ' -metadata title= -metadata artist= -metadata comment=' \
        ' -metadata major_brand= -metadata compatible_brands=' +
        # para teste produz somente segundos
        # ' -t 20' \
        ''
    end

    def aspect_ratio
      # invalido aspect ratio 0:1
      if ratio == '0:1' then bitrate < 720 ? '' : ' -aspect 16:9'
      else                   " -aspect #{ratio}"
      end
    end

    def dimension
      # video dimensions
      if    bitrate <  480 then ' -s hd480'
      elsif bitrate <= 720 then ' -s hd720'
      else                      ' -s hd1080'
      end
    end

    def probe
      "ffprobe -hide_banner -show_streams \"#{video}\" 2>&1|grep -v title"
    end

    def mpeg
      "ffmpeg #{geral} -i #{video} -y -an " +
        # framerate & bitrate
        "-r #{[fps, 25].min} -b:v #{[bitrate, 2000].min}k" +
        dimension + aspect_ratio + metadata
    end

    def processa(dar, din, out)
      return if (bitrate < 3000 && ext == '.mp4') ||
                Time.parse(duration) < Time.parse('00:01:00') ||
                vdok?(dar, out)

      p mpeg + " #{din}/#{out}/#{base}.mp4"
      vfok?(HRVideo.new("#{din}/#{out}/#{base}.mp4"))
    end
  end
end
