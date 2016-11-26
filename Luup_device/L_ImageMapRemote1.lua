-- a-lurker, copyright, 20 Jan 2013
-- Image Map Remote: - a virtual Remote

--[[
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    version 3 (GPLv3) as published by the Free Software Foundation;

    In addition to the GPLv3 License, this software is only for private
    or home usage. Commercial utilisation is not authorized.

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
]]

local PLUGIN_NAME     = 'ImageMapRemote'
local PLUGIN_SID      = 'urn:a-lurker-com:serviceId:'..PLUGIN_NAME..'1'
local PLUGIN_VERSION  = '0.54'
local THIS_LUL_DEVICE = nil

local PLUGIN_URL_ID = 'al_imr'
local URL_ID        = './data_request?id=lr_'..PLUGIN_URL_ID
local ICON_URL      = 'https://a-lurker.github.io/icons/'

local THE_REMOTE = nil

-- must match the keys in the following table 'REMOTES'
-- should be in camel case as shown to match Vera's usage
local REMOTES_LIST = {
    'RgbLed44Key',
    'Basetech'
}

--[[ For debugging only
local REMOTES_LIST = {
    'RgbLed44Key',
    'Basetech',
    'TestCases'
}
]]

--[[
    buttonGrid/buttonSize/buttons:
    The buttons ordered from left to right, top to bottom
    If a button is titled 'Blank' it becomes inactive

    Override rules:
       buttons can be all the same size and in a grid pattern (you specify the grid only) or
       buttons can be all the same size but not in a grid pattern (you specify the button positions only) or
       buttons can be any size and in any position (you specify every single button completely)
       x = left to right  in pixels
       y = top  to bottom in pixels

    buttons.co:
    The code is based on what Company's method
    0 = the code is a Pronto code; you can leave out the fields 'clk' and 'msbLast' from the table
    1 = the code is a typical NEC code or similar
    2 = Basetech - the code uses two sequences, one of which is a NEC sequence; see function 'massageProntoCodes'

    buttons.clk:
    The IR remote transmit clock rate
    38,000 Hz clock rate for a NEC remote is typical.
    Other remotes such as Sony may use 40,000 Hz
    You can shrink or stretch the IR transmission length to
    achieve better reliability by altering the rate here

    buttons.msbLast:
    Determines if the MSB or the LSB of the byte is transmitted first. In genuine NEC codes the MSB
    is sent last but when codes are learned they are generally learnt/interpreted as MSB first.

    buttons.code:
    The final code sent by a NEC remote is four bytes wide
    The d0 (the remote address) is typically the same for all buttons, whereas d2 (the command) varies
    The variable 'code' is a string that can use any separator - a comma is used in the tables below
    2 to 4 bytes must be specified:
       specifying just 2 bytes: output is d0, /d1, d2, /d3  as per the original NEC specification
       specifying just 3 bytes: output is d0,  d1, d2, /d3  where d1 is the extended address together with d0
       specifying 4 bytes: output is exactly as specified providing full control

    buttons.title:
    The button's name eg 'Vol+' will end up as the web page tool tip
    Set the title to 'Blank' to leave out a button
]]

-- one entry per remote control using NEC (preferred) or Pronto codes:
local REMOTES = {

RgbLed44Key = {

    -- name shown to the user
    friendlyName = 'RGB LED 44 key',

    -- the URL of the remote control's image
    imageUrl = ICON_URL..'RemoteRGB44Key_200_467.jpg',

    -- if 'grid' is true the button positions and size are all calculated - the values in 'buttons' are overridden
    buttonGrid = {grid = true, leftOffset = 10, topOffset = 11, width = 200-(10*2), height = 467-(11*2), numberBtnsLeftToRight = 4},

    -- if 'same' is true the button size declared here is used throughout - the sizes in 'buttons' are overridden
    buttonSize = {same = true, width = 15, height = 15},

    -- Thanks to: http://blog.allgaiershops.com/2012/05/10/reversing-an-rgb-led-remote/
    -- depending on 'grid' and 'same' above - we can exert full control over the button positions and sizing
    buttons = {
        {co = 1, clk = 38000, msbLast = false, code = '00,3A', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Brightness + (7 steps)'},
        {co = 1, clk = 38000, msbLast = false, code = '00,BA', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Brightness - (7 steps)'},
        {co = 1, clk = 38000, msbLast = false, code = '00,82', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Pause/Run'},
        {co = 1, clk = 38000, msbLast = false, code = '00,02', xP = 0, yP = 0, xW = 0, yH = 0, title = 'On/Off'},
        {co = 1, clk = 38000, msbLast = false, code = '00,1A', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Red'},
        {co = 1, clk = 38000, msbLast = false, code = '00,9A', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Green'},
        {co = 1, clk = 38000, msbLast = false, code = '00,A2', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Blue'},
        {co = 1, clk = 38000, msbLast = false, code = '00,22', xP = 0, yP = 0, xW = 0, yH = 0, title = 'White'},
        {co = 1, clk = 38000, msbLast = false, code = '00,2A', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Orange'},
        {co = 1, clk = 38000, msbLast = false, code = '00,AA', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Pea green'},
        {co = 1, clk = 38000, msbLast = false, code = '00,92', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Dark blue'},
        {co = 1, clk = 38000, msbLast = false, code = '00,12', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Off-white'},
        {co = 1, clk = 38000, msbLast = false, code = '00,0A', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Dark yellow'},
        {co = 1, clk = 38000, msbLast = false, code = '00,8A', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Cyan'},
        {co = 1, clk = 38000, msbLast = false, code = '00,B2', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Royal blue'},
        {co = 1, clk = 38000, msbLast = false, code = '00,32', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Light pink'},
        {co = 1, clk = 38000, msbLast = false, code = '00,38', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Yellow'},
        {co = 1, clk = 38000, msbLast = false, code = '00,B8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Light blue'},
        {co = 1, clk = 38000, msbLast = false, code = '00,78', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Pink'},
        {co = 1, clk = 38000, msbLast = false, code = '00,F8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Green white'},
        {co = 1, clk = 38000, msbLast = false, code = '00,18', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Light yellow'},
        {co = 1, clk = 38000, msbLast = false, code = '00,98', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Sky blue'},
        {co = 1, clk = 38000, msbLast = false, code = '00,58', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Brown'},
        {co = 1, clk = 38000, msbLast = false, code = '00,D8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Blue white'},
        {co = 1, clk = 38000, msbLast = false, code = '00,28', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Increase red'},
        {co = 1, clk = 38000, msbLast = false, code = '00,A8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Increase green'},
        {co = 1, clk = 38000, msbLast = false, code = '00,68', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Increase blue'},
        {co = 1, clk = 38000, msbLast = false, code = '00,E8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Speed up'},
        {co = 1, clk = 38000, msbLast = false, code = '00,08', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Decrease red'},
        {co = 1, clk = 38000, msbLast = false, code = '00,88', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Decrease green'},
        {co = 1, clk = 38000, msbLast = false, code = '00,48', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Decrease blue'},
        {co = 1, clk = 38000, msbLast = false, code = '00,C8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Speed down'},
        {co = 1, clk = 38000, msbLast = false, code = '00,30', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Mem 1'},
        {co = 1, clk = 38000, msbLast = false, code = '00,B0', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Mem 2'},
        {co = 1, clk = 38000, msbLast = false, code = '00,70', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Mem 3'},
        {co = 1, clk = 38000, msbLast = false, code = '00,F0', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Automatic change'},
        {co = 1, clk = 38000, msbLast = false, code = '00,10', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Mem 4'},
        {co = 1, clk = 38000, msbLast = false, code = '00,90', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Mem 5'},
        {co = 1, clk = 38000, msbLast = false, code = '00,50', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Mem 6'},
        {co = 1, clk = 38000, msbLast = false, code = '00,D0', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Flash on and off'},
        {co = 1, clk = 38000, msbLast = false, code = '00,20', xP = 0, yP = 0, xW = 0, yH = 0, title = '3 color change'},
        {co = 1, clk = 38000, msbLast = false, code = '00,A0', xP = 0, yP = 0, xW = 0, yH = 0, title = '7 color change'},
        {co = 1, clk = 38000, msbLast = false, code = '00,60', xP = 0, yP = 0, xW = 0, yH = 0, title = '3 color fade change'},
        {co = 1, clk = 38000, msbLast = false, code = '00,E0', xP = 0, yP = 0, xW = 0, yH = 0, title = '7 color fade change'}
    }
},

-- Basetech remote
-- http://www.conrad.de/ce/de/product/361131/Basetech-LED-RGB-mit-IR-Fernbedienung-E27-37W-Globeform
-- codes: http://wiki.micasaverde.com/index.php/BASETech_RGB_LED
Basetech = {

    -- name shown to the user
    friendlyName = 'Basetech',

    -- the URL of the remote control's image
    imageUrl = ICON_URL..'BasetechRGBled_200_300.jpg',

    -- if 'grid' is true the button positions and size are all calculated - the values in 'buttons' are overridden
    buttonGrid = {grid = true, leftOffset = 6, topOffset = 5, width = 200-(6*2), height = 300-(5*2), numberBtnsLeftToRight = 4},

    -- if 'same' is true the button size declared here is used throughout - the sizes in 'buttons' are overridden
    buttonSize = {same = true, width = 15, height = 15},

    -- depending on 'grid' and 'same' above - we can exert full control over the button positions and sizing
    buttons = {
        {co = 2, clk = 38000, msbLast = false, code = '00,00', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Blank'},  -- this button in the grid is blank
        {co = 2, clk = 38000, msbLast = false, code = '00,00', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Blank'},  -- this button in the grid is blank
        {co = 2, clk = 38000, msbLast = false, code = '00,78', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Off'},
        {co = 2, clk = 38000, msbLast = false, code = '00,F8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'On'},
        {co = 2, clk = 38000, msbLast = false, code = '00,18', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Red'},
        {co = 2, clk = 38000, msbLast = false, code = '00,98', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Green'},
        {co = 2, clk = 38000, msbLast = false, code = '00,58', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Blue'},
        {co = 2, clk = 38000, msbLast = false, code = '00,D8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Dim 100'},
        {co = 2, clk = 38000, msbLast = false, code = '00,20', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Red 1'},
        {co = 2, clk = 38000, msbLast = false, code = '00,A0', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Green 1'},
        {co = 2, clk = 38000, msbLast = false, code = '00,60', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Blue 1'},
        {co = 2, clk = 38000, msbLast = false, code = '00,E0', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Dim 80'},
        {co = 2, clk = 38000, msbLast = false, code = '00,10', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Red 2'},
        {co = 2, clk = 38000, msbLast = false, code = '00,90', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Green 2'},
        {co = 2, clk = 38000, msbLast = false, code = '00,50', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Blue 2'},
        {co = 2, clk = 38000, msbLast = false, code = '00,D0', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Dim 60'},
        {co = 2, clk = 38000, msbLast = false, code = '00,30', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Red 3'},
        {co = 2, clk = 38000, msbLast = false, code = '00,B0', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Green 3'},
        {co = 2, clk = 38000, msbLast = false, code = '00,70', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Blue 3'},
        {co = 2, clk = 38000, msbLast = false, code = '00,F0', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Dim 40'},
        {co = 2, clk = 38000, msbLast = false, code = '00,08', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Red 4'},
        {co = 2, clk = 38000, msbLast = false, code = '00,88', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Green 4'},
        {co = 2, clk = 38000, msbLast = false, code = '00,48', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Blue 4'},
        {co = 2, clk = 38000, msbLast = false, code = '00,C8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Dim 20'},
        {co = 2, clk = 38000, msbLast = false, code = '00,28', xP = 0, yP = 0, xW = 0, yH = 0, title = 'White'},
        {co = 2, clk = 38000, msbLast = false, code = '00,A8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Auto Color'},
        {co = 2, clk = 38000, msbLast = false, code = '00,68', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Store color'},
        {co = 2, clk = 38000, msbLast = false, code = '00,E8', xP = 0, yP = 0, xW = 0, yH = 0, title = 'Next Color'}
    }
},

-- This was used only for debugging and is not required - it just remains
-- as an example and could be modified to be an additional remote
TestCases = {

    -- name shown to the user
    friendlyName = 'Test cases',

    -- the URL of the remote control's image
    imageUrl = ICON_URL..'IR_Transmitter.png',

    -- if 'grid' is true the button positions and size are all calculated - the values in 'buttons' are overridden
    buttonGrid = {grid = true, leftOffset = 0, topOffset = 0, width = 50, height = 50, numberBtnsLeftToRight = 3},

    -- if 'same' is true the button size declared here is used throughout - the sizes in 'buttons' are overridden
    buttonSize = {same = true, width = 15, height = 15},

    -- depending on 'grid' and 'same' above - we can exert full control over the button positions and sizing
    buttons = {
        {co = 1, clk = 38000, msbLast = false, code = '00,FF,02,FD', xP = 0, yP = 0, xW = 0, yH = 0, title = '1'},  -- RGB 44 key
        {co = 1, clk = 38000, msbLast = false, code = '00 02',       xP = 0, yP = 0, xW = 0, yH = 0, title = '2'},  -- RGB 44 key
        {co = 1, clk = 38000, msbLast = false, code = '5E,A1,D8,27', xP = 0, yP = 0, xW = 0, yH = 0, title = '3'},  -- Yamaha
        {co = 1, clk = 38000, msbLast = false, code = '5E,D8',       xP = 0, yP = 0, xW = 0, yH = 0, title = '4'},  -- Yamaha
        {co = 1, clk = 38000, msbLast = false, code = '0A,80,30,CF', xP = 0, yP = 0, xW = 0, yH = 0, title = '5'},  -- Topfield
        {co = 1, clk = 38000, msbLast = false, code = '0A,80,30',    xP = 0, yP = 0, xW = 0, yH = 0, title = '6'}   -- Topfield
    }
}
}

-- You can turn on Verbose Logging - refer to: Vera-->U15-->SETUP-->Logs-->Verbose_Logging
-- http://vera_ip_address/cgi-bin/cmh/log_level.sh?command=enable&log=VERBOSE
-- http://vera_ip_address/cgi-bin/cmh/log_level.sh?command=disable&log=VERBOSE
local DEBUG_MODE = false

local function debug(textParm, logLevel)
    if DEBUG_MODE then
        local text = ''
        local theType = type(textParm)
        if (theType == 'string') then
            text = textParm
        else
            text = 'type = '..theType..', value = '..tostring(textParm)
        end
        luup.log(PLUGIN_NAME..' debug: '..text,50)

    elseif (logLevel) then
        local text = ''
        if (type(textParm) == 'string') then text = textParm end
        luup.log(PLUGIN_NAME..' debug: '..text, logLevel)
    end
end

-- Round towards 0 with precision
local function round(num, idp)
    local mult = 10^(idp or 0)
    if (num >= 0) then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

-- Justify a string
-- s: string to justify
-- width: width to justify to (+ve means right-justify; negative means left-justify)
-- [padder]: string to pad with (" " if omitted)
-- returns s: justified string
local function pad(s, width, padder)
    padder = string.rep(padder or " ", math.abs(width))
    if (width < 0) then
        return string.sub(padder..s, width) end
    return string.sub(s..padder, 1, width)
end

-- Convert a decimal string to a string of base of binary power x padded with leading zeros to match width
local function dec2StrInBase(dec, base, width)
    local chrSet = '0123456789ABCDEF'
    local intVar = 0
    local result = ''

    dec = tonumber(dec)
    while dec > 0 do
        intVar = math.mod  (dec,base) + 1
        dec    = math.floor(dec/base)
        result = string.sub(chrSet,intVar,intVar)..result
    end

    return pad (result, -width, '0')
end

-- Convert a hexadecimal string to a binary string padded with leading zeros to match width
local function hex2Bin(hex, width)
    local dec = tonumber(hex, 16)
    bin = dec2StrInBase(dec, 2, 8)
    return bin
end

-- Invert a binary string of arbitary length
local function invBin(bin)
    bin = bin:gsub ('0', '@')
    bin = bin:gsub ('1', '0')
    bin = bin:gsub ('@', '1')
    return bin
end

--[[
NEC code timing characteristics:
Frame length is supposedly 110 mSec
Lead in:  9ms mark then 4.5ms space
logic 1:  560uS mark then 1690uS space
logic 0:  560uS mark then 560uS space
Lead out: 560uS mark
Lead out: the remaining time to make up the 110 mSec frame length

Payload:
byte 0 = address
byte 1 = typically byte 0 complemented but is sometimes used as an extended address byte
byte 2 = command
byte 3 = byte 2 complemented - may be used as extended data but I've never seen this
]]

-- Converts a NEC code (or similar) to the pronto code equivalent
-- http://www.sbprojects.com/knowledge/ir/nec.php
local function NEC2Pronto(IRclkFrequency, msbLast, NECcode)

    -- controls the transmit bit rate
    IRclkFrequency = IRclkFrequency or 38000

    -- controls the bit ordering on transmit
    msbLast = msbLast or false

    -- The Pronto apparently used a Motorola DragonBall MC68328PV16VA
    -- These CPUs typically used a 16.67 MHz xtal: divide that by 4 and you get
    -- 4.16775 MHz. noting that PWM in the CPU has a minimum divide rate of 4
    -- Does any one know the actual crystal frequency used in the Pronto?
    -- This constant is found here: http://www.remotecentral.com/features/irdisp2.htm
    -- 1e6/0.241246 = 4,145,146 Hz is commonly used:
    local PRONTO_CLK = 4145146.0 -- Hz

    -- 38000 becomes 38028.86 Hz after rounding
    -- hardware divides by integers
    local prontoDiv = round(PRONTO_CLK/IRclkFrequency)
    local IRclk     = PRONTO_CLK/prontoDiv

    local bitsLeadOut = round(110.0e-3  * IRclk)
    local bits9000    = round(  9.0e-3  * IRclk)
    local bits4500    = round(  4.5e-3  * IRclk)
    local bits1690    = round(  1.69e-3 * IRclk)
    local bits560     = round(  0.56e-3 * IRclk)

    -- all table entries are hexadecimal
    local pTab = {}

    -- convert to hexadecimal
    prontoDiv = dec2StrInBase(prontoDiv, 16, 4)

    local bits9000h = dec2StrInBase(bits9000, 16, 4)
    local bits4500h = dec2StrInBase(bits4500, 16, 4)
    local bits1690h = dec2StrInBase(bits1690, 16, 4)
    local bits560h  = dec2StrInBase(bits560,  16, 4)

    -- start preamble
    table.insert(pTab, '0000')     -- code is learned
    table.insert(pTab, prontoDiv)  -- Pronto divider

    -- The first  sequence is the IR code for sending a code only once
    -- The second sequence is the IR code to be used when it is sent repeatedly
    -- If a sequence is not required, it is set to '0000'
    -- If two sequences are used; they may or may not be the same code

    -- For NEC codes:
    -- number of burst pairs in sequence #1
    -- none: sequence is blank, codes are considered repeatable
    table.insert(pTab, '0000')

    -- number of burst pairs in sequence #2
    -- leadin + address + data + leadout = 1+8+8+8+8+1 = 34dec = 22hex
    table.insert(pTab, '0022')
    -- end preamble

    -- start sequence #2
    table.insert(pTab, bits9000h)   -- lead in mark
    table.insert(pTab, bits4500h)   -- lead in space
    bitsLeadOut = bitsLeadOut - bits9000 - bits4500

    local fieldWidth = 8

    -- will contain the four bytes (address and data) as binary strings
    local txTab = {}

    -- split out the hex codes
    local opStr = ''
    for hexStr in NECcode:gmatch('%x+') do
        table.insert(txTab, hex2Bin(hexStr, fieldWidth))
        opStr = opStr..' '..hexStr
    end
    debug ('Input  code:'..opStr)

    -- Originally d1 and d3 were just inversions of d0 and d2. This helped to ready the IR receiver's AGC system.
    -- Some recent remotes use d1 together with d0 as an extended address. In this case d1 is not inverted.
    -- Make the d1 & d3 inversions as required
    if (#txTab < 2) or (#txTab > 4) then
        debug('txTab is too short or too long')
        return ''
    elseif (#txTab == 2) then  -- d1 and d3 are just d0 and d2 inverted
        table.insert(txTab, 2, invBin(txTab[1]))
        table.insert(txTab, invBin(txTab[3]))
    elseif (#txTab == 3) then  -- d1 is an extended address and d3 = not d2
        table.insert(txTab, invBin(txTab[3]))
    end

    if (#txTab ~= 4) then debug ('txTab is not the correct length: '..#txTab) return '' end

    -- reverse the transmitted bit order?
    if msbLast then
        for k,v in ipairs(txTab) do
            txTab[k] = v:reverse()
        end
    end

    if DEBUG_MODE then
        local opTab = {}
        for k,v in ipairs(txTab) do
            local decStr = tonumber(v,2)
            local hexStr = dec2StrInBase(decStr, 16, 2)
            table.insert(opTab, hexStr)
        end
        debug ('Output code: '..table.concat(opTab,' '))
    end

    -- generate the address and data bit bursts
    for k,v in ipairs(txTab) do
        for i = 1, fieldWidth, 1 do
            if string.sub(v,i,i) == '1' then
                -- logic 1
                table.insert(pTab, bits560h)   -- mark
                table.insert(pTab, bits1690h)  -- space
                bitsLeadOut = bitsLeadOut - bits560 - bits1690
            else
                -- logic 0
                table.insert(pTab, bits560h)   -- mark
                table.insert(pTab, bits560h)   -- space
                bitsLeadOut = bitsLeadOut - bits560 - bits560
            end
        end
    end

    table.insert(pTab, bits560h) -- lead out mark
    bitsLeadOut = bitsLeadOut - bits560

    local bitsLeadOuth = dec2StrInBase(bitsLeadOut,  16, 4)
    table.insert(pTab, bitsLeadOuth) -- lead out space
    -- end sequence #2

    -- return the pronto code
    return table.concat(pTab,' ')
end

-- adjust codes for those that aren't truely NEC
local function massageProntoCodes(btn)
    local prontoCode = ''

    -- NEC code?
    if (btn.co == 1) then
        return NEC2Pronto(btn.clk, btn.msbLast, btn.code)

    -- Basetech?
    elseif (btn.co == 2) then
        prontoCode = NEC2Pronto(btn.clk, btn.msbLast, btn.code)

        -- this is a total hack to make this remote work
        prontoCode = prontoCode:gsub('0000 0022', '0024 0000')  -- remote swaps sequence count location
        prontoCode = prontoCode..' 0152 0058 0015 0E4E'         -- and always appends these two bytes
        return prontoCode
    end

    -- default to a plain Pronto code
    return btn.code
end

-- For debugging purposes only: shows all the input and output codes for the remote
local function logProntoCodes(remoteInfo)
    -- generate all the codes for this remote
    if DEBUG_MODE then
        debug ('Code list follows:')
        for k,v in ipairs(remoteInfo.buttons) do
            local prontoCode = massageProntoCodes(v)
            debug ('Pronto code: '..prontoCode)
        end
    end
end

-- Automatically fills in the button layout information if possible.
-- Otherwise it has to be declared manually for each button in the table
local function fleshOutButtons(remoteInfo)
    if (remoteInfo.buttonGrid.grid) then
        -- generate all the button positions and sizes

        -- x buttons by y buttons
        local bCntLR = remoteInfo.buttonGrid.numberBtnsLeftToRight
        local bCntTB = math.ceil(#remoteInfo.buttons/bCntLR)

        -- size of each button left to right and top to bottom in pixels
        local xWidth  = round(remoteInfo.buttonGrid.width/bCntLR)
        local yHeight = round(remoteInfo.buttonGrid.height/bCntTB)

        -- keep track of the current button
        local btnIdx = 1

        -- top side corner of the grid
        local yPos = remoteInfo.buttonGrid.topOffset
        for i = 1, bCntTB, 1 do
            -- left side of the grid
            local xPos = remoteInfo.buttonGrid.leftOffset
            for i = 1, bCntLR, 1 do
                -- the buttons may not fill the whole grid
                if remoteInfo.buttons[btnIdx] then
                    local btn = remoteInfo.buttons[btnIdx]
                    btn.xP = xPos
                    btn.yP = yPos
                    btn.xW = xWidth
                    btn.yH = yHeight
                end
                xPos = xPos + xWidth
                btnIdx = btnIdx + 1
            end
            yPos = yPos + yHeight
        end
    elseif remoteInfo.buttonSize.same then
        -- generate all the button sizes but the buttons
        -- positions have to be filled in manually
        for k,v in ipairs(remoteInfo.buttons) do
            remoteInfo.buttons[k].xW = remoteInfo.buttonSize.width
            remoteInfo.buttons[k].yH = remoteInfo.buttonSize.height
        end
    end
    -- bad luck: the table has to be completely filled in by hand!
end

-- Make the html <area> tags for the image map
local function getAreas(remoteInfo)
    local areasTab = {}

    -- produce the button area for each button
    for k,v in ipairs(remoteInfo.buttons) do
        local btn = remoteInfo.buttons[k]

        -- leave out buttons titled 'Blank'
        if (btn.title ~= 'Blank') then
            debug(btn.xP..','..btn.yP..','..btn.xW..','..btn.yH)

            -- default to rectangular buttons - json encoded, so do not place double quotes in html string
            table.insert(areasTab, "<area alt='"..k.."' coords='"..btn.xP..","..btn.yP..","..(btn.xP+btn.xW)..","..(btn.yP+btn.yH).."' title='"..btn.title.."' onclick='remoteBtnClick("..k..")'/>")
        end
    end

    return table.concat(areasTab)
end

-- This returns the html for the list of all available remotes as json
-- The results ends up in a pull down list for the user in the UI
function getRemoteNameList()
    local htmlTab = {
    '{"remoteList": "',  -- where \\u0022 = double quotes
    "<select id='listOfRemotes' class='styled' onChange='set_device_state("..THIS_LUL_DEVICE..",\\u0022"..PLUGIN_SID.."\\u0022,\\u0022RemoteName\\u0022,this.value);'>",
    "<option value='0'>-- Please select --</option>"}

    for k,v in ipairs(REMOTES_LIST) do
        local selected = ''
        if (REMOTES[v] == THE_REMOTE) then
            selected = " selected='selected'"
        end

        table.insert(htmlTab,"<option value='"..v.."'"..selected..">"..REMOTES[v].friendlyName.."</option>")
    end

    table.insert(htmlTab,'</select>"}')

    -- note that linefeeds aren't allowed in the json
    local html = table.concat(htmlTab)
    debug(html)

    return html
end

-- This returns the html for the 'Image Map Remote' tab as json
local function getImageMap(remoteInfo)
    -- json encoded, so do not place double quotes in html string
    local htmlTab = {
    '{"imageMap": "',
    "<div>",
    "<img src='"..remoteInfo.imageUrl.."' alt='remoteMapImage' usemap='#remoteMap' style='border:none'/>",
    "<map id='remoteMap' name='remoteMap'>",
    getAreas(remoteInfo),
    "</map>",
    "</div>",
    '"}'
    }

    -- note that linefeeds aren't allowed in the json
    local imageMap = table.concat(htmlTab)
    debug(imageMap)

    return imageMap
end

-- Transmit the IR signal depending on the button pushed
-- function SendRemoteCode (lul_device, lul_settings)
--    sendRemoteCode(lul_settings.buttonNumber)
local function sendRemoteCode(buttonNumber)
    local btnNumber = tonumber(buttonNumber or '1')

    local btn = THE_REMOTE.buttons[btnNumber]
    if (not btn) then return false end

     -- got a real world IR TX device? If not forget the whole thing
    local ioDevice = luup.variable_get('urn:micasaverde-com:serviceId:HaDevice1', 'IODevice', THIS_LUL_DEVICE)
    if ((not ioDevice) or (ioDevice == '') or (not luup.devices[ioDevice])) then
        debug('The IOdevice was nil or not found', 50)
        return false
    end

    ioDevice = tonumber(ioDevice)
    local prontoCode = massageProntoCodes(btn)

    debug('Sending code for "'..btn.title..'" button number '..btnNumber..': '..prontoCode, 50)

    luup.call_action('urn:micasaverde-com:serviceId:IrTransmitter1', 'SendProntoCode', {ProntoCode=prontoCode}, ioDevice)
end

-- Entry point for all function calls via ajax
-- http://vera_ip_address/port_3480/data_request?id=lr_al_imr
function requestMain (lul_request, lul_parameters, lul_outputformat)
    debug('request is: '..tostring(lul_request))
    for k,v in pairs(lul_parameters) do debug ('parameters are: '..tostring(k)..'='..tostring(v)) end
    debug('outputformat is: '..tostring(lul_outputformat))

    if not (lul_request:lower() == PLUGIN_URL_ID) then return end

    -- set the parameters key and value to lower case
    local lcParameters = {}
    for k, v in pairs(lul_parameters) do lcParameters[k:lower()] = v:lower() end

    if not lcParameters.fnc then return '{}' end

    -- return the Ajax result
    if (lcParameters.fnc == 'getimagemap')       then return getImageMap(THE_REMOTE) end
    if (lcParameters.fnc == 'getremotenamelist') then return getRemoteNameList() end
    return '{}'
end

-- Start up the plugin
-- Refer to: I_ImageMapRemote1.xml
-- <startup>luaStartUp</startup>
function luaStartUp(lul_device)
    THIS_LUL_DEVICE = lul_device

    luup.variable_set(PLUGIN_SID, 'PluginVersion', PLUGIN_VERSION, THIS_LUL_DEVICE)

    -- First time round we need to set up an 'unconfigured' state variable that will hold the I/O port/device.
    -- Set it to empty as it's unconfigured. The user will select an I/O device in the device settings later.
    local newIODevice = luup.variable_get('urn:micasaverde-com:serviceId:HaDevice1', 'IODevice', THIS_LUL_DEVICE)
    debug(newIODevice)
    if (not newIODevice) then luup.variable_set('urn:micasaverde-com:serviceId:HaDevice1', 'IODevice', '', THIS_LUL_DEVICE) end

    local remoteName = luup.variable_get(PLUGIN_SID, 'RemoteName', THIS_LUL_DEVICE)
    debug(remoteName)

    local found = false

    -- if the remoteName is nil or not in the list of remotes use the default
    if (remoteName) then
        for k,v in ipairs(REMOTES_LIST) do
            if v == remoteName then
                found = true
                -- set the remote to use
                THE_REMOTE = REMOTES[remoteName]
            end
        end
    end

    -- use the default
    if (not found) then
        -- the first remote in the list becomes the default
        THE_REMOTE = REMOTES[REMOTES_LIST[1]]
        luup.variable_set(PLUGIN_SID, 'RemoteName', REMOTES_LIST[1], THIS_LUL_DEVICE)
    end

    debug('Remote is: '..THE_REMOTE.friendlyName)

    -- If the buttons occupy a simple grid, then this fills in all the button positions. If all the buttons are
    -- all the same size, it fills them in as well. Otherwise you have to load the table by hand for each button.
    fleshOutButtons(THE_REMOTE)

    -- runs during debug only
    logProntoCodes(THE_REMOTE)

    -- registers a handler for the functions called via ajax
    luup.register_handler('requestMain', PLUGIN_URL_ID)

    -- on success
    return true, 'All OK', PLUGIN_NAME
end
