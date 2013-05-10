package com.kenshisoft.captions.models
{
	/**
	 * ...
	 * @author 
	 */
	public interface IEvent
	{
		function get id():int;
       	function set id(value:int):void;
		function get startSeconds():Number;
		function set startSeconds(value:Number):void;
		function get endSeconds():Number;
       	function set endSeconds(value:Number):void;
		function get duration():Number;
       	function set duration(value:Number):void;
	}
}
