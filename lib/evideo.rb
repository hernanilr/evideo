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
    class_option :d, banner: 'DIR', type: :array,
                     default: ["/home/#{ID}/lust", "/media/#{ID}/hrv2"],
                     desc: 'Onde procurar videos'
    class_option :i, banner: 'IN', default: 'ftv',
                     desc: 'Pasta origem'
    desc 'conv', 'converte videos'
    option :o, banner: 'OUT', default: 'out',
               desc: 'Pasta destino'
    # Processa videos
    def conv
      dar = options[:d]
      Dir.glob("#{dar.first}/#{options[:i]}/*.???").sort.each do |f|
        HRVideo.new(f).processa(dar, dar.first, options[:o])
      end
    end

    desc 'test', 'testa videos'
    # Analisa videos
    def test
      Dir.glob("#{options[:d].first}/#{options[:i]}/*.???").sort.each do |f|
        p HRVideo.new(f).testa
      end
    end
    default_task :conv
  end
end
