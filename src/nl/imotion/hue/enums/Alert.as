package nl.imotion.hue.enums
{
    /**
     * @author Pieter van de Sluis
     */
    public class Alert
    {

        // ____________________________________________________________________________________________________
        // PUBLIC

        public static const NONE:String = "none";
        public static const SELECT:String = "select";
        public static const LONG_SELECT:String = "lselect";


        public static function getAll():Array
        {
            return [ NONE, SELECT, LONG_SELECT ];
        }

    }
}