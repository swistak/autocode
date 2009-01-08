module AutoCode
  
  # always make sure we have a camel-cased symbol
  def AutoCode.normalize( cname )
    return cname  unless cname.is_a? Symbol or cname.is_a? String
    camel_case( cname )
  end
  
  def AutoCode.camel_case( cname )  
    cname.to_s.gsub(/^([a-z])/) { $1.upcase }.gsub(/(_)(\w)/) { $2.upcase }.intern
  end
  
  def AutoCode.snake_case( cname )
    cname.to_s.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
  end
        
  def self.extended( mod ) ; included( mod ) ; end

  def self.included( mod )
    
    mod.instance_eval do

      # First make sure we haven't already done this once
      return unless @autocode.nil?
      
      # Initialize bookkeeping variables needed by AutoCode
      @autocode = { 
        :constructors => Hash.new { |h,k| h[k] = [] },
        :initializers => Hash.new { |h,k| h[k] = [] },
        :loaded => []
      }
      
      def auto_constructor( key = true, &block)
        @autocode[:constructors][ AutoCode.normalize( key ) ] << block
      end
      
      def auto_create( key = true, options = {}, &block )
        auto_constructor( key ) do | cname |
          exemplar = options[:exemplar] || Module.new
          new_constant = exemplar.clone
          new_constant.send(:include, AutoCode)
          new_constant.module_eval( &block ) if block
          const_set( cname, new_constant )
        end
      end
      
      # Convenience method for auto_creating classes.
      def auto_create_class( key = true, parent = Object, &block )
        auto_constructor( key ) do | cname |
          parent = const_get(parent) unless parent.is_a? Class
          new_constant = Class.new( parent )
          new_constant.send(:include, AutoCode)
          new_constant.module_eval( &block ) if block
          const_set( cname, new_constant )
        end
      end

      # Convenience method for auto_creating modules.
      def auto_create_module( key = true, &block )
        auto_constructor( key ) do | cname |
          new_constant = Module.new
          new_constant.send(:include, AutoCode)
          new_constant.module_eval( &block ) if block
          const_set( cname, new_constant )
        end
      end

      # Adds an auto_load block for the given key and directories
      def auto_load( key = true, options = {} )
        @autocode[:constructors][ AutoCode.normalize( key ) ] << lambda do | cname |
          filename = AutoCode.snake_case( cname ) << '.rb'
          options[:directories] ||= '.'
          path = options[:directories].
            map { |dir| File.join( dir.to_s, filename ) }.
            find { |path| File.exist?( path ) }
          Kernel.load( path ) unless path.nil?
        end
      end

      # Adds an arbitrary initializer block for the given key
      def auto_eval( key, &block )
        if key.is_a?( Symbol) && const_defined?( AutoCode.normalize( key ) )
          const_get( key ).module_eval &block
        else
          @autocode[:initializers][ AutoCode.normalize( key ) ] << lambda do | mod |
            mod.module_eval( &block )
          end
        end
      end


      # Returns the list of constants that would be reloaded upon a call to reload.
      def reloadable ; @autocode[:loaded] ; end

      # Reloads (via #remove_const) all the constants that were loaded via auto_code.
      def reload ; @autocode[:loaded].each { |name| remove_const( name ) } ; @autocode[:loaded] = [] ; end

      private

      old = method( :const_missing )
      (class << self ; self ; end ).instance_eval do
        define_method( :const_missing ) do | cname |
          constructors = @autocode[:constructors][true] + @autocode[:constructors][cname]
          constructors.reverse.find { | c | c.call( cname ) and const_defined?( cname ) }
          return old.call( cname ) unless const_defined?( cname )          
          initializers = @autocode[:initializers][true] + @autocode[:initializers][cname]
          mod = const_get( cname ); initializers.each { |init| init.call( mod ) }
          @autocode[:loaded] << cname
          mod
        end
      end
    end
  end
end
Autocode = AutoCode