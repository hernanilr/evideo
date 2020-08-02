# frozen_string_literal: true

require 'time'

module Evideo
  # permite analizar/processar videos para arquivo
  class HRVideo
    # @return [String] tempo: rate:
    def show
      return nome unless @probe

      "tempo: #{tempo} rate: #{bitrate} ratio: #{ratio} height: #{height}"
    end

    # Testa validade video original
    #
    # @param [String] aot pasta destino dos videos absoluta
    # @return [true, false] sim ou nao video original esta ok
    def ofok?(aot)
      return false unless processa_of?

      puts "mv \"#{nome} #{aot}/#{base}.mp4\" # #{show}"
      true
    end

    # @return [true, false] video original precisa ser processado?
    def processa_of?
      # prossecar somente videos grandes (>1 min) ou extensao errada ou bitrate >= 3000
      ((bitrate < 3000 && ext == '.mp4') || Time.parse(tempo) < Time.parse('00:01:00')) &&
        # prossecar somente videos com ratio, height, audio errados
        ratio == '16:9' && height > 480 && audio.zero?
    end

    # Testa validade video processado contra video original
    #
    # @param [String] hrv video processado a testar validade
    # @return [true, false] sim ou nao video esta ok
    def vfok?(hrv)
      return false unless File.exist?(hrv.nome) && hrv.bitrate < 3000 && Time.parse(hrv.tempo) > Time.parse(tempo) - 60

      puts "rm \"#{nome}\" # #{hrv.nome} #{hrv.show}"
      true
    end

    # Testa validade videos processados em todos locais contra video original
    #
    # @param [Array<String>] ary array locais onde procurar videos
    # @param [String] pot pasta destino dos videos
    # @return [true, false] sim ou nao <local>/<video> esta ok
    def vdok?(ary, pot)
      if ary.empty? then false
      elsif vfok?(HRVideo.new("#{ary.first}/#{pot}/#{base}.mp4")) then true
      else  vdok?(ary.drop(1), pot)
      end
    end

    # @return [String] aspect ratio comando conversao
    def aspect
      if ratio == '0:1' then height < 720 ? '' : ' -aspect 16:9'
      else " -aspect #{ratio}"
      end
    end

    # @return [String] video dimensions comando conversao
    def dimension
      if    height <  480 then ' -s hd480'
      elsif height <= 720 then ' -s hd720'
      else                     ' -s hd1080'
      end
    end

    # @return [String] comando analise
    def cmd_probe
      "ffprobe -hide_banner -show_streams \"#{nome}\" 2>&1|grep -v title"
    end

    # Comando para processar videos
    #
    # @param [String] tempo do video processado
    # @return [String] comando conversao
    def cmd_mpeg(tempo)
      puts "processar #{base}.mp4 " + join_opcoes
      "ffmpeg #{geral} -i \"#{nome}\" -y -an " + join_opcoes +
        ' -metadata title= -metadata artist= -metadata comment= -metadata major_brand= -metadata compatible_brands=' +
        # para teste produz somente segundos
        tempo
    end

    # @return [String] opcoes para trabalho framerate & bitrate & dimenssoes
    def join_opcoes
      "-r #{[fps, 25].min} -b:v #{[bitrate, 2000].min}k" + dimension + aspect
    end

    # @return [String] opcoes gerais comando conversao
    def geral
      '-loglevel quiet -hide_banner' +
        # para ignorar segundos no inicio
        # ' -ss 15' \
        ''
    end

    # Processa videos
    #
    # @param [Hash] opcoes parametrizacao
    # @option opcoes [Array<String>] :d locais onde procurar videos
    # @option opcoes [<String>] :i pasta origem dos videos
    # @option opcoes [<String>] :o pasta destino dos videos
    # @option opcoes [<Boolean>] :t processa somente segundos para teste
    # @param [String] aot pasta destino dos videos absoluta
    def processa(opcoes, aot)
      return if ofok?(aot) || vdok?(opcoes[:d], opcoes[:o])

      system cmd_mpeg(opcoes[:t] ? ' -t 20' : '') + " #{aot}/#{base}.mp4"
      vfok?(HRVideo.new("#{aot}/#{base}.mp4"))
    end

    # Testa videos
    #
    # @param [Hash] opcoes parametrizacao
    # @option opcoes [Array<String>] :d locais onde procurar videos
    # @option opcoes [<String>] :i pasta origem dos videos
    # @option opcoes [<String>] :o pasta destino dos videos
    # @option opcoes [<Boolean>] :t processa somente segundos para teste
    # @param [String] aot pasta destino dos videos absoluta
    def testa(opcoes, aot)
      return if ofok?(aot) || vdok?(opcoes[:d], opcoes[:o])

      puts "ls -lh \"#{nome}\" # #{show}"
    end
  end
end
