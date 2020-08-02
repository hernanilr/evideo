# frozen_string_literal: true

require 'thor'
require 'evideo/version'
require 'evideo/hrvideo'
require 'evideo/hrvprocessa'

module Evideo
  class Error < StandardError; end
  ID = `whoami`.chomp
  # CLI para analisar/processar videos
  class CLI < Thor
    class_option :d, banner: 'DIR', type: :array, desc: 'Onde procurar videos',
                     default: ["/home/#{ID}/lust", "/media/#{ID}/hrv2"]
    class_option :i, banner: 'IN',  default: 'ftv', desc: 'Pasta origem'
    class_option :o, banner: 'OUT', default: 'out', desc: 'Pasta destino'

    desc 'conv', 'converte videos'
    option :t, type: :boolean, default: false, desc: 'Processa somente segundos para teste'
    def conv
      Dir.glob("#{fin}/*.???").sort.each do |f|
        HRVideo.new(f).processa(options, fout)
      end
    end

    desc 'test', 'testa videos'
    def test
      Dir.glob("#{fin}/*.???").sort.each do |f|
        HRVideo.new(f).testa(options, fout)
      end
    end

    default_task :test
    no_commands do
      # @return [String] pasta absoluta origem dos videos
      def fin
        "#{options[:d].first}/#{options[:i]}"
      end

      # @return [String] pasta absoluta destino dos videos
      def fout
        "#{options[:d].first}/#{options[:o]}"
      end
    end
  end
end
