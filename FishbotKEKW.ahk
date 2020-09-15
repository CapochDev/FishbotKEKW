/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

#Include Lib\VA.ahk

#SingleInstance, Force

audioMeter := VA_GetAudioMeter()

greenBarColor = 0x437922
redBarColor = 0xd3420d
blueBarColor = 0x2a5790

mode = 1
pulling = 1

spot1X = 0
spot1Y = 0
spot2X = 0
spot2Y = 0
spot3X = 0
spot3Y = 0

Esc::ExitApp


F4::
    loopCount = 0
    modeCount = 0

    currentSpotX = %spot1X%
    currentSpotY = %spot1Y%

    Loop
    {   
        Random, rand, -20, 20
        thisX := currentSpotX + rand
        thisY := currentSpotY + rand

        Click %thisX%, %thisY%, down
        Random, rand, 850, 1050
        Sleep %rand%
        Click up

        Sleep 2000

        k = 0
        Loop
        {   
            k++
            if k > 300000
                break
            VA_IAudioMeterInformation_GetPeakValue(audioMeter, peakValue)
            if peakValue > 0.011
            {
                Random, rand, 0, 450
                Sleep %rand%
                break
            }
        }

        Click

        ;Sleep required for the correct behave of the exit loop checker, keep over 0.4s
        Sleep 300

        pulling = 1
        SetTimer, checkIfPulling, -1
        SetTimer, checkIfPulling, 100

        Sleep 200

        while pulling
        {
            if !pulling
                break

            Click down

            Loop
            {
                if !pulling
                    break

                PixelSearch Px, Py, 990, 554, 990, 554, %greenBarColor%, 50, RGB
                if ErrorLevel
                    break
            }

            Click up
            Sleep 100
        }

        SetTimer, checkIfPulling, Delete

        if loopCount = 12
        {
            useFishBait()
            loopCount = 0
        }
        else
            loopCount++

        if mode = 3 
        {
            if (modeCount = 4)
            {
                currentSpotX = %spot2X%
                currentSpotY = %spot2Y%
            }
            if (modeCount = 8)
            {
                currentSpotX = %spot3X%
                currentSpotY = %spot3Y%
            }
            if (modeCount = 12)
            {
                currentSpotX = %spot1X%
                currentSpotY = %spot1Y%
                modeCount = 0
            }
        }
        else if mode = 2
        {
            if (modeCount = 4)
            {
                currentSpotX = %spot2X%
                currentSpotY = %spot2Y%
            }
            if (modeCount = 8)
            {
                currentSpotX = %spot1X%
                currentSpotY = %spot1Y%
                modeCount = 0
            }
        }

        modeCount++

        Random, rand, 4500, 6000
        Sleep %rand%
    }
return


useFishBait()
{

    Sleep 200
    MouseGetPos, xpos, ypos
    Send {1}
    Sleep 1400
    Send {i}
    Sleep 200
    Click 1590, 555, Right
    Sleep 200
    Send {i}
    Sleep 200
    MouseMove %xpos%, %ypos%

}


F3::

    mode = 3
    ToolTip , Click on the first spot...
    KeyWait, LButton, D
    MouseGetPos, spot1X, spot1Y
    Sleep 200
    Send {s}
    ToolTip , Click on the second spot...
    KeyWait, LButton, D
    MouseGetPos, spot2X, spot2Y
    Sleep 200
    Send {s}
    ToolTip , Click on the third spot...
    KeyWait, LButton, D
    MouseGetPos, spot3X, spot3Y
    Sleep 200
    Send {s}
    ToolTip , Spots selection completed, press F4 to start fishing!
    SetTimer, RemoveToolTip, -2500

return

F2::

    mode = 2
    ToolTip , Click on the first spot...
    KeyWait, LButton, D
    MouseGetPos, spot1X, spot1Y
    Sleep 200
    Send {s}
    ToolTip , Click on the second spot...
    KeyWait, LButton, D
    MouseGetPos, spot2X, spot2Y
    Sleep 200
    Send {s}
    ToolTip , Spots selection completed, press F4 to start fishing!
    SetTimer, RemoveToolTip, -2500

return

F1::

    mode = 1
    ToolTip , Click on the first spot...
    KeyWait, LButton, D
    MouseGetPos, spot1X, spot1Y
    Sleep 200
    Send {s}
    ToolTip , Spots selection completed, press F4 to start fishing!
    SetTimer, RemoveToolTip, -2500

return


RemoveToolTip:
ToolTip
return


F12::

    ToolTip , %spot1X%x%spot1Y%`n%spot2X%x%spot2Y%`n%spot3X%x%spot3Y%

return


checkIfPulling:

    PixelSearch Px, Py, 840, 588, 840, 588, %blueBarColor%, 30, RGB
    if ErrorLevel
        pulling = 0

return