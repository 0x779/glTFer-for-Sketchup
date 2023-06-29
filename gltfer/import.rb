# glTFer extension for SketchUp
# Copyright: © 0x779 <https://github.com/0x779>


require 'sketchup'
require 'gltfer/main'

module Gltfer
    class Import

        def initialize()
            select_source_file

            return unless @source_file_path.is_a?(String)

            @source_dir = File.dirname(@source_file_path)

            import_gltf_glb(@source_file_path)
        end 


        def select_source_file

            @source_file_path = UI.openpanel('Select GLTF/GLB file', '', 'GLTF Files|*.gltf;*.glb|AllFiles|*.*')

        end
        
        def import_gltf_glb(file_path)

            model = Sketchup.active_model

            # Delete everything
            if $b_DeleteEverything
                model.entities.clear!
                while Sketchup.active_model.materials.size > 0
                    material = Sketchup.active_model.materials[0]
                    Sketchup.active_model.materials.remove(material)
                end
            end

            # Create a new component definition to hold the imported GLTF/GLB model
            definitions = model.definitions
            component_definition = definitions.add "gltf"

            # Import the GLTF/GLB file into the component definition
            importer = model.import(file_path, true)

            # Check if the component definition is valid before adding the instance
            if component_definition.valid?
                # Create a new instance of the component definition
                instance = component_definition.instances.add(Geom::Transformation.new)

                # Add the instance to the active entities collection
                model.active_entities.add(instance)
                geometry = instance.definition.entities

                calculate_vertex_normals(component_definition.entities)

                # Apply scaling and transformation to the imported component
                instance = entities.grep(Sketchup::ComponentInstance).find { |i| i.definition == component_definition }
                scale_factor = 1.0 / importer.bounds.diagonal
                transformation = Geom::Transformation.scaling(scale_factor) * Geom::Transformation.new
                instance.transformation = transformation

            else
                puts "Component definition is not valid"
            end


            # Fix for alpha to transparency conversion
            model = Sketchup.active_model
            model.materials.each { |material|
                #material.alpha = 1.0 - material.alpha  -  disabled for now as software packages have different ways in which they write the alpha/opacity data
                material.alpha = 1.0
            }            

            # Zoom extents to show the whole model
            view = model.active_view
            view.zoom_extents
        end

        def calculate_vertex_normals(entities)
            entities.each do |entity|
                next unless entity.is_a?(Sketchup::Face)

                # Calculate the face normal
                face_normal = entity.normal
                
                # Set the vertex normals based of face orientation and adjacency
                entity.vertices.each do |vertex|
                    vertex.normal = calculate_smooth_vertex_normal(vertex, face_normal)
                end
            end
        end

        def calculate_smooth_vertex_normal(vertex, face_normal)
            smooth_normal = Geom::Vector3d.new

            vertex.faces.each do |face|
                # Skip the face if it's not a smooth face (different smoothing group)
                next if face.normal.samedirection?(face_normal)

                # Add the face normal to the smooth normal
                smooth_normal += face_normal
            end
            
            # Normalize the resulting smooth normal
            smooth_normal.normalize!

            smooth_normal
        end

    # Last instance of Import class.
    #
    # @see ModelObserver#onPlaceComponent
    @@last = nil

    # Gets last instance of Import class.
    #
    # @return [UniversalImporter::Import, nil]
    def self.last
      @@last
    end

    # Sets or forgets last instance of Import class.
    #
    # @param [UniversalImporter::Import, nil] instance
    #
    # @raise [ArgumentError]
    def self.last=(instance)
      raise ArgumentError, 'Instance must be an gltfer::Import or nil'\
        unless instance.is_a?(Import) || instance.nil?

      @@last = instance
    end



    end 
end