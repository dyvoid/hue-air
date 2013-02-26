package nl.imotion.hue.entities
{
    import flash.utils.Dictionary;


    /**
     * @author Pieter van de Sluis
     */
    public class HueGroup extends HueEntity
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        private var _lights:Vector.<HueLight>;
        private var _lightsDictionary:Dictionary;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueGroup( id:String, propsObject:Object = null )
        {
            super( id );

            _lights = new  Vector.<HueLight>();
            _lightsDictionary = new Dictionary();

            if ( propsObject )
            {
                fromObject( propsObject );
            }
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function fromObject( propsObject:Object ):void
        {
            try
            {
                basePropsFromObject( propsObject.action );
                name = propsObject.name;

                isInvalid = false;
            }
            catch ( e:Error )
            {
                throw new Error( "Properties object is invalid" );
            }
        }


        public function addLight( light:HueLight ):void
        {
            _lights.push( light );
            _lightsDictionary[ light.id ] = light;
        }


        public function getLightByID( id:String ):HueLight
        {
            return _lightsDictionary[ id ];
        }

        // ____________________________________________________________________________________________________
        // PRIVATE


        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        public function get lights():Vector.<HueLight>
        {
            return _lights;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}