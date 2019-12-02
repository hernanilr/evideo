# frozen_string_literal: true

require 'thor'
require 'evideo/version'
require 'evideo/hrvideo'

module Evideo
  class Error < StandardError; end
  ID = `whoami`.chomp
  # CLI para processar videos
  class CLI < Thor
    class_option :d, banner: 'DIR', type: :array,
                     default: ["/home/#{ID}/lust", "/media/#{ID}/hrv2"],
                     desc: 'Onde procurar videos'
    class_option :i, banner: 'IN', default: 'ftv',
                     desc: 'Pasta origem'
    desc 'conv', 'converte videos'
    option :o, banner: 'OUT', default: 'out',
               desc: 'Pasta destino'
    def conv
      dar = options[:d]
      Dir.glob(File.join(dar[0], options[:i], '*.???')).sort.each do |f|
        HRVideo.new(f).processa(dar, dar[0], options[:o])
      end
    end
    default_task :conv
  end
end
