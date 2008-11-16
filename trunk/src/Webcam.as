﻿package {	/* JPEGCam v1.0 */	/* Webcam library for capturing JPEG images and submitting to a server */	/* Copyright (c) 2008 Joseph Huckaby <jhuckaby@goldcartridge.com> */	/* Licensed under the GNU Lesser Public License */	/* http://www.gnu.org/licenses/lgpl.html */    	import flash.display.LoaderInfo;	import flash.display.Sprite;    import flash.display.StageAlign;    import flash.display.StageScaleMode;	import flash.display.BitmapData;    import flash.events.*;	import flash.utils.*;    import flash.media.Camera;    import flash.media.Video;	import flash.external.ExternalInterface;	import flash.net.*;	import flash.system.Security;    import flash.system.SecurityPanel;	import flash.media.Sound;    import flash.media.SoundChannel;	import com.adobe.images.JPGEncoder;    public class Webcam extends Sprite {        private var video:Video;		private var encoder:JPGEncoder;		private var snd:Sound;		private var channel:SoundChannel = new SoundChannel();		private var jpeg_quality:int;		private var video_width:int;		private var video_height:int;                public function Webcam() {			var flashvars:Object = LoaderInfo(this.root.loaderInfo).parameters;			video_width = Math.floor( flashvars.width );			video_height = Math.floor( flashvars.height );			            stage.scaleMode = StageScaleMode.NO_SCALE;            stage.align = StageAlign.TOP_LEFT;                        var camera:Camera = Camera.getCamera();						camera.setQuality(0, 100);			camera.setKeyFrameInterval(10);			// camera.setMode(stage.stageWidth, stage.stageHeight, 15);			camera.setMode(video_width, video_height, 15);						                        if (camera != null) {                camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);                video = new Video(video_width, video_height);                video.attachCamera(camera);                addChild(video);            } 			else {                trace("You need a camera.");				ExternalInterface.call('webcam.flash_notify', "error", "No camera was detected.");            }						ExternalInterface.addCallback('_snap', snap);			ExternalInterface.addCallback('_configure', configure);						if (flashvars.shutter_enabled == 1) {				snd = new Sound();				snd.load( new URLRequest( flashvars.shutter_url ) );			}						jpeg_quality = 90;						ExternalInterface.call('webcam.flash_notify', 'flashLoadComplete', true);        }				public function set_quality(new_quality:int) {			if (new_quality < 0) new_quality = 0;			if (new_quality > 100) new_quality = 100;			jpeg_quality = new_quality;		}        		public function configure(panel:String = SecurityPanel.CAMERA) {			Security.showSettings(panel);		}		        private function activityHandler(event:ActivityEvent):void {            trace("activityHandler: " + event);        }				public function onLoaded(evt:Event):void {			var msg = "unknown";			if (evt && evt.target && evt.target.data) msg = evt.target.data;			ExternalInterface.call('webcam.flash_notify', "success", msg);		}				public function snap(url, new_quality, shutter) {			if (new_quality) set_quality(new_quality);			trace("in snap(), drawing to bitmap");						if (shutter) {				channel = snd.play();				setTimeout( snap2, 10, url );			}			else snap2(url);		}				public function snap2(url) {			// take snapshot, convert to jpeg, submit to server			var bmpdata:BitmapData = new BitmapData(video_width, video_height);			bmpdata.draw(video);						trace("converting to jpeg");						var ba:ByteArray;			encoder = new JPGEncoder( jpeg_quality );			ba = encoder.encode( bmpdata );						trace("jpeg length: " + ba.length);						var head:URLRequestHeader = new URLRequestHeader("Accept","text/*");			var req:URLRequest = new URLRequest( url );			req.requestHeaders.push(head);						req.data = ba;			req.method = URLRequestMethod.POST;			req.contentType = "image/jpeg";						var loader:URLLoader = new URLLoader();			loader.addEventListener(Event.COMPLETE, onLoaded);						trace("sending post to: " + url);						try {				loader.load(req);			} 			catch (error:Error) {				trace("Unable to load requested document.");				ExternalInterface.call('webcam.flash_notify', "error", "Unable to post data: " + error);			}		}    }}