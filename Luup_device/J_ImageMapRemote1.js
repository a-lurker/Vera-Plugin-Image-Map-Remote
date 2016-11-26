// ----------------------------------------------------------------------------
// Written by a-lurker 22 Jan 2013
// ----------------------------------------------------------------------------

var PLUGIN_NAME     = 'ImageMapRemote';
var PLUGIN_SID      = 'urn:a-lurker-com:serviceId:'+PLUGIN_NAME+'1';
var THIS_LUL_DEVICE = null;
var URL_PART        = '/port_3480/data_request';
var PLUGIN_URL_ID   = 'al_imr'

// some predefined variables in U15:
// data_request_url = http://Vera_IP_address/port_3480/data_request? -- the trailing '?' causes problems
// data_command_url = http://Vera_IP_address/port_3480
// command_url      = http://Vera_IP_address/port_49451

// ----------------------------------------------------------------------------
// This suits the user defined calls lr_***
// See http://prototypejs.org/doc/latest/ajax/index.html
// ----------------------------------------------------------------------------

function callLuaFunction (args, callBack)
{
   if (args     === undefined) {args     = null;}
   if (callBack === undefined) {callBack = null;}

   var q = {  // all case sensitive
      id: 'lr_'+PLUGIN_URL_ID
   };

   // extend the parms object with any additional arguments
   var key;
   for (key in args) {
      q[key] = args[key];
   }

   new Ajax.Request (URL_PART, {
      method: 'get',
      parameters: q,
      evalJSON: 'force',   // 22 Jan 2013:  Vera U15, firmware 1.5.408 doesn't set the mime type for json
      onSuccess:  function (response) {
         if (callBack) {
            var jsonResponse = JSON.parse(response.responseText);
            callBack (jsonResponse);
         }},
      onFailure:  function (response) {},
      onComplete: function (response) {}
   });
}

// ----------------------------------------------------------------------------
// This suits the conventional lu_action calls
// See http://prototypejs.org/doc/latest/ajax/index.html
// ----------------------------------------------------------------------------

function callAction (device, sid, action, args, callBack)
{
   if (args     === undefined) {args     = null;}
   if (callBack === undefined) {callBack = null;}

   var q = {  // all case sensitive
      id: 'lu_action',
      serviceId: sid,
      action: action,
      DeviceNum: device,
      output_format: 'xml',
      rand: Math.random()
   };

  // extend the parms object with any additional arguments
   var key;
   for (key in args) {
      q[key] = args[key];
   }

   new Ajax.Request (URL_PART, {
      method: 'get',
      parameters: q,
      onSuccess:  function (response) {},
      onFailure:  function (response) {},
      onComplete: function (response) {}
   });
}

// ----------------------------------------------------------------------------
// The Image Map has been returned
// ----------------------------------------------------------------------------

function getImageMapResponse (jsonObj)
{
   var html = '<div>Image map failed to load</div>';

   if (jsonObj && jsonObj.imageMap) {html = jsonObj.imageMap;}

   set_panel_html(html);
}

// ----------------------------------------------------------------------------
// Entry point for the Keypad Tab: Declaring this function name in the D_***.json
// file results in this function being called by the Tab drawing code.
// ----------------------------------------------------------------------------

function runKeypadTab (device)
{
   if (THIS_LUL_DEVICE === null) {THIS_LUL_DEVICE = device;};

   // use an Ajax call to get the remote control layout
   callLuaFunction ({fnc:'getImageMap'}, getImageMapResponse);
}

function get_infrared_transmitters_pulldown_UI5(deviceID,force){
        if(force!=undefined){
            return get_infrared_transmitters_pulldown_wizzard(deviceID)
        } else {
            var currentTransmitter=get_device_state(deviceID,HADEVICE_SID,HAD_IOPORT_DEVICE);
            var html='';
            var roomsNo=jsonp.ud.rooms.length;
            var devicesNo=jsonp.ud.devices.length;
            if(devicesNo>0){
                    html='<select id="ir_transmitter" class="styled" onChange="set_device_state('+deviceID+',\''+HADEVICE_SID+'\',\''+HAD_IOPORT_DEVICE+'\',this.value);">'
                    html+='<option value="0" selected>-- '+"Please select"+' --</option>';

                    for(var devicePos=0;devicePos<devicesNo;devicePos++){
                            var deviceObj=jsonp.ud.devices[devicePos];
                            if(deviceObj.commProv=='ir'){
                                    html+='<option value="'+jsonp.ud.devices[devicePos].id+'" '+((jsonp.ud.devices[devicePos].id==currentTransmitter)?'selected':'')+'>#'+jsonp.ud.devices[devicePos].id+' '+deviceObj.name+' ('+get_room_name(deviceObj.room)+')</option>';
                            }
                    }
                    html+='</select>';
            }else{
                    html='';
            }

            return html;
        }
}

// ----------------------------------------------------------------------------
// Set up the remotes pulldown list and the IR I/O ports pulldown list
// ----------------------------------------------------------------------------

function getRemoteNameListResponse (jsonObj)
{
   var html = '<div>Remote list failed to load</div>';

   if (jsonObj && jsonObj.remoteList)
   {
      // list the available remotes and the available IR ports
      html = '<table>';
      html += '<tr><td>'+"Select remote"+'</td>';
      html += '<td>'+jsonObj.remoteList+'</td></tr>';
      html += '<tr><td>'+"Infrared transmitter&nbsp;&nbsp;"+'</td>';
      // this function was originally part of shared.js in cpanel_data.js
      // in UI5 but is not found in UI7
      html += '<td>'+get_infrared_transmitters_pulldown_UI5(THIS_LUL_DEVICE)+'</td></tr>';
      html += '</table>';
   }

   set_panel_html(html);
}

// ----------------------------------------------------------------------------
// Entry point for the Settings Tab: Declaring this function name in the D_***.json
// file results in this function being called by the Tab drawing code.
// ----------------------------------------------------------------------------

function runSettingsTab (device)
{
   if (THIS_LUL_DEVICE === null) {THIS_LUL_DEVICE = device;};

   // use an Ajax call to get the remote list layout
   callLuaFunction ({fnc:'getRemoteNameList'}, getRemoteNameListResponse);
}

// ----------------------------------------------------------------------------
// The user clicked a button on the virtual remote - go transmit the IR signal
// ----------------------------------------------------------------------------

function remoteBtnClick (button)
{
   callAction (THIS_LUL_DEVICE, PLUGIN_SID, 'SendRemoteCode', {buttonNumber: button} );

   return false;
}

