# frozen_string_literal: true

require 'thor'
require 'evideo/vars'
require 'evideo/processa'
require 'evideo/version'

# (see Evideo)
module Evideo
  who = `whoami`.chomp
  ADI = ["/home/#{who}/lust", "/media/#{who}/hrv2", "/media/#{who}/hrv2/lust"].freeze

  # CLI para analisar/processar videos
  class CLI < Thor
    class_option :d, banner: 'DIR', type: :array, desc: 'Onde procurar videos', default: ADI
    class_option :i, banner: 'IN', default: 'ftv', desc: 'Pasta inicial'
    class_option :o, banner: 'OUT', default: 'out', desc: 'Pasta final'

    # TODO: convert jpg -> mp4
    # ffmpeg -pattern_type glob -r 0.15 -i '*.jpg' -c:v libx264 -pix_fmt yuv420p -s 720x480 ../../lily95.mp4

    desc 'conv', 'converte videos'
    option :x, type: :boolean, default: false, desc: 'executa/mostra comando converte videos'
    option :s, type: :numeric, default: 0, desc: 'Segundos cortados no inicio do video final 0=sem cortes'
    option :t, type: :numeric, default: 0, desc: 'Segundos duracao video final 0=sem cortes'
    # converte videos
    def conv
      # cria pasta final para videos processados
      system("mkdir -p #{ipasta}/#{options[:o]}")

      Dir.glob("#{ipasta}/*.???").sort.each do |file|
        Video.new(file, options).processa
      end
    end

    desc 'test', 'testa videos'
    # testa videos
    def test
      Dir.glob("#{ipasta}/*.???").sort.each do |file|
        puts(Video.new(file, options).inout)
      end
    end

    default_task :test
    no_commands do
      # @return [String] pasta absoluta inicial dos videos
      def ipasta
        "#{options[:d][0]}/#{options[:i]}"
      end
    end
  end
end
