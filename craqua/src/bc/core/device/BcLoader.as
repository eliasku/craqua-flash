package bc.core.device
{
	/**
	 * @author weee
	 */
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class BcLoader
	{
		public static const LOADER_IMAGE : String = "image";
		public static const LOADER_SOUND : String = "sound";
		public static const LOADER_XML : String = "xml";
		public var id : String;
		public var type : String;
		public var path : String;
		private var loader : Object;
		private var data : Object;
		private var callback : BcLoaderCallback;
		private var descLoader : Boolean;
		public var metaAlpha : Boolean = true;

		public function BcLoader(type : String, id : String, path : String, callback : BcLoaderCallback, descLoader:Boolean)
		{
			this.type = type;
			this.path = path;
			this.id = id;
			this.callback = callback;
			this.descLoader = descLoader;

			var request : URLRequest = new URLRequest(path);

			try
			{
				switch(type)
				{
					case LOADER_IMAGE:
						loader = new Loader();
						loader.load(request);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageComplete, false, 0, true);
						break;
					case LOADER_SOUND:
						loader = new Sound();
						loader.load(request);
						loader.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
						loader.addEventListener(Event.COMPLETE, onSoundComplete, false, 0, true);
						break;
					case LOADER_XML:
						loader = new URLLoader();
						loader.load(request);
						loader.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
						loader.addEventListener(Event.COMPLETE, onXMLComplete, false, 0, true);
						break;
				}
			}
			catch (error : Error)
			{
				log(error.message);
				finish();
			}
		}

		private function onImageComplete(event : Event) : void
		{
			data = Bitmap(Loader(loader).content).bitmapData;
			finish();
		}

		private function onXMLComplete(event : Event) : void
		{
			data = XML(URLLoader(loader).data);
			finish();
		}

		private function onSoundComplete(event : Event) : void
		{
			data = Sound(loader);
			finish();
		}

		private function onError(event : IOErrorEvent) : void
		{
			log(event.text);
			finish();
		}

		private function finish() : void
		{
			loader = null;
			if (descLoader)
			{
				callback.onDescriptionLoaded(this);
			}
			else
			{
				callback.onResourceLoaded(this);
			}
			callback = null;
		}

		private function log(msg : String) : void
		{
			trace(id + ' (' + path + '): ' + msg);
		}

		public function get bitmapData() : BitmapData
		{
			return BitmapData(data);
		}

		public function get sound() : Sound
		{
			return Sound(data);
		}

		public function get xml() : XML
		{
			return XML(data);
		}
	}
}