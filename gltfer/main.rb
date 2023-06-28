# glTFer extension for SketchUp
# Copyright: © 0x779 <https://github.com/0x779>

require 'sketchup'
require 'gltfer/import'

module Gltfer
    $b_DeleteEverything = true
    unless file_loaded?(__FILE__)
        menu = UI.menu('Plugins')
        menu.add_item('glTFer Import file...') {
            Import.last = Import.new
        }
        file_loaded(__FILE__)
    end
end