# Copyright 2016 Trimble Inc
# Licensed under the MIT license

require 'sketchup.rb'
require 'extensions.rb'

module Gltfer
    unless file_loaded?(__FILE__)
        ex = SketchupExtension.new('glTFer', 'gltfer/main')
        ex.description = 'glTF/gLB importer for SketchUp.'
        ex.version     = '1.0.0'
        ex.copyright   = '0x779 © 2023'
        ex.creator     = '0x779'
        Sketchup.register_extension(ex, true)
        file_loaded(__FILE__)
    end

end
