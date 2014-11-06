
require 'singleton'

module Hwk

  class Hwkline
    attr_accessor :hwk_line, :maps_to

    def initialize( line: nil, map: nil )
      @hwk_line = line
      @maps_to = map
    end

  end

  class Hwktracer
    include Singleton
    attr_accessor :lines

    def initialize
      @lines = {}
    end

    def update( obj: nil, name: nil, line_info: nil, value: nil )
      if obj.nil? or name.nil? or line_info.nil? or value.nil?
        return
      end

      obj_id = obj.object_id
      @lines[obj_id] = {} unless @lines.has_key?( obj_id )
      @lines[obj_id].store( name, Hwkline.new( line: line_info, map: value ) )
    end

    def dump
      puts "HWKTRACE DUMP ++ "
      @lines.each { |obj_id,v|
        puts "  #{obj_id} -> #{ObjectSpace._id2ref(obj_id).to_sym}: "
        v.each { |vk,vv|
          puts "    #{vk} - #{vv.hwk_line}"
          puts "    #{' '*vk.length} - #{vv.maps_to}"
        }
      }
      puts "HWKTRACE DUMP -- "
    end

  end

  HWKTRACE = Hwktracer.instance
end

