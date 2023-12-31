--wrong version, read instructions
--Uncomment the following line if this is a Cheat Table format trainer and you don't want CE to show (Tip, save as .CETRAINER alternatively)
--hideAllCEWindows()

RequiredCEVersion=7.4
if (getCEVersion==nil) or (getCEVersion()<RequiredCEVersion) then
  messageDialog('Please install Cheat Engine '..RequiredCEVersion, mtError, mbOK)
  closeCE()
end
getAutoAttachList().add("bg3.exe")
--getAutoAttachList().add("bg3_dx11.exe")

--Hotkey Script https://www.cheatengine.org/forum/viewtopic.php?t=602091&sid=50c9f9e1a64b033758025ebbfe7e8ca4

local changeHotkeyKeysForm
local hotkeys = {}
local userDefinedKeys = {}
local hotkeysKeysSettings

local function userPressedKey(sender, key)
  if userDefinedKeys[5]==0 then
    for i=1,5 do
      if userDefinedKeys[i]==0 then
        userDefinedKeys[i]=key
        break
      else
        if userDefinedKeys[i]==key then break end
      end
    end
  end

  changeHotkeyKeysForm.CEEdit1.Text=convertKeyComboToString(userDefinedKeys)
  return 0
end

local function clearHotkey()
  userDefinedKeys={0,0,0,0,0}
  changeHotkeyKeysForm.CEEdit1.Text=convertKeyComboToString(userDefinedKeys)
  changeHotkeyKeysForm.CEEdit1.setFocus()
end

local function formCreate()
  changeHotkeyKeysForm=createForm(false)
  changeHotkeyKeysForm.Name = 'changeHotkeyKeysForm'
  changeHotkeyKeysForm.Caption = 'Change Hotkey Keys'
  changeHotkeyKeysForm.Width = 300
  changeHotkeyKeysForm.Height = 120
  changeHotkeyKeysForm.Position = poScreenCenter
  changeHotkeyKeysForm.OnClose =
     function ()
       changeHotkeyKeysForm.CEEdit1.setFocus()
       return caHide
     end

  local CELabel1=createLabel(changeHotkeyKeysForm)
  CELabel1.Name = 'CELabel1'
  CELabel1.Left = 20
  CELabel1.Top = 20
  CELabel1.Caption = 'Set hotkey:'

  local CEEdit1=createEdit(changeHotkeyKeysForm)
  CEEdit1.Name = 'CEEdit1'
  CEEdit1.Text = ''
  CEEdit1.AnchorSideLeft.Control = CELabel1
  CEEdit1.AnchorSideTop.Control = CELabel1
  CEEdit1.AnchorSideTop.Side = asrBottom
  CEEdit1.Height = 25
  CEEdit1.Width = 248
  CEEdit1.BorderSpacing.Top = 4

  local clearButton=createButton(changeHotkeyKeysForm)
  clearButton.Name = 'clearButton'
  clearButton.AnchorSideLeft.Control = CEEdit1
  clearButton.AnchorSideTop.Control = CEEdit1
  clearButton.AnchorSideTop.Side = asrBottom
  clearButton.Height = 30
  clearButton.Width = 80
  clearButton.BorderSpacing.Top = 8
  clearButton.Caption = 'Clear'

  local applyButton=createButton(changeHotkeyKeysForm)
  applyButton.Name = 'applyButton'
  applyButton.AnchorSideLeft.Control = clearButton
  applyButton.AnchorSideLeft.Side = asrBottom
  applyButton.AnchorSideTop.Control = clearButton
  applyButton.Height = 30
  applyButton.Width = 80
  applyButton.BorderSpacing.Left = 10
  applyButton.Caption = 'Apply'

  CEEdit1.OnKeyDown = userPressedKey
  local mbtn={false,true,true,true}
  CEEdit1.OnMouseDown = function (s,k) if mbtn[k] then s.OnKeyDown(s,k+2) end end
  clearButton.OnClick = clearHotkey    -- clear button
  applyButton.ModalResult = mrYes      -- apply button
end

local function updateControlWithHotkeyString(ctrl,hotkey)
  local hotkeyString
  if hotkey.ClassName=='TMemoryRecordHotkey' then
    hotkeyString = convertKeyComboToString(hotkey.Keys)
  else
    hotkeyString = convertKeyComboToString{hotkey.getKeys()}
  end

  if ctrl.ClassName=='tcheat' then
    ctrl.Hotkey = hotkeyString
  else -- not a tcheat component
    if ctrl.Text then
      ctrl.Text = hotkeyString
    elseif ctrl.Caption then
      ctrl.Caption = hotkeyString
    end
  end
end

local function getHotkeyFromRegistry(hotkeyName,hotkey)
  local str = hotkeysKeysSettings.Value[hotkeyName]
  if str=='' then return end
  local keys={0,0,0,0,0}
  local i=1
  for v in str:gmatch'[^,]+' do
    keys[i] = tonumber(v)
    i=i+1
  end
  if hotkey.ClassName=='TMemoryRecordHotkey' then
    hotkey.Keys = keys
  else
    hotkey.setKeys(keys[1],keys[2],keys[3],keys[4],keys[5])
  end
end

local function setHotkeyInRegistry(hotkeyName,hotkey)
  if hotkey.ClassName=='TMemoryRecordHotkey' then
    hotkeysKeysSettings.Value[hotkeyName] = table.concat(hotkey.Keys,',')
  else
    hotkeysKeysSettings.Value[hotkeyName] = table.concat({hotkey.getKeys()},',')
  end
end

local function createUniqueHotkeyName(hotkey,index)
  local name = ''..index
  if hotkey.ClassName=='TMemoryRecordHotkey' then
    name = name..'_'..hotkey.Owner.Description..'_'..hotkey.Description..'_'..
                      hotkey.Owner.ID..'_'..hotkey.ID
  end
  return name
end


function changeHotkeyKeys(hotkey,ctrl)
  if not changeHotkeyKeysFormCreated then
    changeHotkeyKeysFormCreated = true
    formCreate()
  end

  if hotkey==nil then return end

  userDefinedKeys={0,0,0,0,0}

  local changed = false

  if hotkey.ClassName=='TGenericHotkey' then
    for i,v in ipairs({hotkey.getKeys()}) do
      userDefinedKeys[i]=v
    end
    changeHotkeyKeysForm.CEEdit1.Text=convertKeyComboToString(userDefinedKeys)
    if changeHotkeyKeysForm.showModal()==mrYes then
      hotkey.setKeys(userDefinedKeys[1],userDefinedKeys[2],
                     userDefinedKeys[3],userDefinedKeys[4],
                     userDefinedKeys[5])
      changed = true
    end

  elseif hotkey.ClassName=='TMemoryRecordHotkey' then
    for i,v in ipairs(hotkey.Keys) do
      userDefinedKeys[i]=v
    end
    changeHotkeyKeysForm.CEEdit1.Text=convertKeyComboToString(userDefinedKeys)
    if changeHotkeyKeysForm.showModal()==mrYes then
      hotkey.Keys = userDefinedKeys
      changed = true
    end
  end

  if changed and (ctrl~=nil) then
   updateControlWithHotkeyString(ctrl,hotkey)
  end
end

function addChangeHotkeyKeysFunctionality(ctrl, hotkey)
  if not ( inheritsFromControl(ctrl) and
           inheritsFromObject(hotkey) and
           ( hotkey.ClassName=='TMemoryRecordHotkey' or hotkey.ClassName=='TGenericHotkey')
         ) then return end

  local btn = createButton(ctrl.Owner)
  btn.Parent = ctrl.Parent
  btn.AnchorSideTop.Control = ctrl
  btn.Height = ctrl.Height
  btn.Width = 15
  btn.Caption = '…'
  if ctrl.ClassName=='tcheat' then
    btn.AnchorSideLeft.Control = ctrl
    btn.BorderSpacing.Left = ctrl.Descriptionleft - 20
  else -- not a tcheat component
    btn.Anchors = '[akTop, akRight]'
    btn.AnchorSideRight.Control = ctrl
    btn.BorderSpacing.Right = 5
  end
  hotkeys[1+#hotkeys] = {control=ctrl,hotkey=hotkey}
  btn.OnClick = function () changeHotkeyKeys(hotkey,ctrl) end
end

function hotkeysSettings(action)
  if     action:lower()=='save' then
    if hotkeysKeysSettings==nil then error'hotkeys settings path not defined' end
    for i,v in ipairs(hotkeys) do
      local name = createUniqueHotkeyName(v.hotkey,i)
      setHotkeyInRegistry(name,v.hotkey)
    end
  elseif action:lower()=='load' then
    if hotkeysKeysSettings==nil then error'hotkeys settings path not defined' end
    for i,v in ipairs(hotkeys) do
      local name = createUniqueHotkeyName(v.hotkey,i)
      getHotkeyFromRegistry(name,v.hotkey)
      updateControlWithHotkeyString(v.control,v.hotkey)
    end
  else
    hotkeysKeysSettings=getSettings(action)
  end

end

--Settings Variables
local minDistVaL = "0"
--local minDist2Val = "0"
local maxDistVal = "0"
--local maxDist2Val = "0"
local FOVVal = "0"
local scrollSpeedVal = "0"
local zoomSpeedVal = "0"
local pitchMinVal = "0"
local pitchMaxVal = "0"
local pitchMinCVal = "0"
local pitchMaxCVal = "0"
local camAngle1Val = "0"
local camAngle2Val = "0"
local tactMinVal = "0"
local tactMaxVal = "0"
hotkeysSettings('BG3\\CameraModHotkey')

--Offset Varibles
-----------------------
--for vulkan
local app = "bg3.exe"
local rax = "057C87B0"
-----------------------
--for dx11
--local app = "bg3_dx11.exe"
--local rax = "05537420"
-----------------------
--dx11 GOG
--local app = "bg3_dx11.exe"
--local rax = "0552EFD0"
-----------------------
local baseAddress = "[" .. app .. "+" .. rax .. "]"
local offsetMin = "7B8"
--local offsetMinn = "C4C"
local offsetMax = "7B4"
--local offsetMaxx = "C48"
local FOVC = "810" --fov close
local FOVF = "814" --fov far
local scrollSpeed = "83C"
local zoomSpeed = "838" --this is weird idk zoom steps?
--local pitchMin = "CCC" --old
--local pitchMax = "CC0" --old
local pitchMinC = "CE4" --old
local pitchMaxC = "CD8" --old
local camAngle1 = "8EC"
local camAngle2 = "8F0"
local tactMin = "854"
local tactMax = "858"
local hud = "19" --old
local camHeight = "7F0"
local camDis = "860"

-----------------------
--vk version
local version_rax = "05805B78"
-----------------------
--dx11 version
--local version_rax = "055747E8"
-----------------------
local version_offset = "270"
local version = "[" .. app .. "+" .. version_rax .. "]"

--8EC an angle
--8F0 an angle
--87C cam lower speed or lower something

--Hotkey Settings Save/Load
function hotkeyLoad(sender)
  hotkeysSettings('BG3\\CameraModHotkey')
  hotkeysSettings('load')
end

function hotkeySave(sender)
  hotkeysSettings('BG#\\CameraMod')
  hotkeysSettings('save')
end

--Values Settings Save/Load
function settingLoad(sender)
  settings=getSettings('BG3\\CameraModValue')
  minDistVaL=settings.Value['minDistVaL']
  maxDistVal=settings.Value['maxDistVal']
  CamDistVal=settings.Value['CamDistVal']
  FOVCVal=settings.Value['FOVCVal']
  FOVFVal=settings.Value['FOVFVal']
  scrollSpeedVal=settings.Value['scrollSpeedVal']
  zoomSpeedVal=settings.Value['zoomSpeedVal']
  --pitchMinVal=settings.Value['pitchMinVal']
  --pitchMaxVal=settings.Value['pitchMaxVal']
  pitchMinCVal=settings.Value['pitchMinCVal']
  pitchMaxCVal=settings.Value['pitchMaxCVal']
  camAngle1Val=settings.Value['camAngle1Val']
  --camAngle2Val needs to be neagitve
  camAngle2Val=settings.Value['camAngle2Val']
  tactMinVal=settings.Value['tactMinVal']
  tactMaxVal=settings.Value['tactMaxVal']
  writeFloat(baseAddress .. offsetMin, minDistVaL)
  writeFloat(baseAddress .. offsetMax, maxDistVal)
  writeFloat(baseAddress .. camDis, CamDistVal)
  writeFloat(baseAddress .. FOVF, FOVFVal)
  writeFloat(baseAddress .. FOVC, FOVCVal)
  writeFloat(baseAddress .. scrollSpeed, scrollSpeedVal)
  writeFloat(baseAddress .. zoomSpeed, zoomSpeedVal)
  --writeFloat(baseAddress .. pitchMin, pitchMinVal)
  --writeFloat(baseAddress .. pitchMax, pitchMaxVal)
  writeFloat(baseAddress .. pitchMinC, pitchMinCVal)
  writeFloat(baseAddress .. pitchMaxC, pitchMaxCVal)
  writeFloat(baseAddress .. camAngle1, camAngle1Val)
  writeFloat(baseAddress .. camAngle2, camAngle2Val)
  writeFloat(baseAddress .. tactMin, tactMinVal)
  writeFloat(baseAddress .. tactMax, tactMaxVal)
end

function settingSave(sender)
  settings=getSettings('BG3\\CameraModValue')
  settings.Value['minDistVaL']=getProperty(UDF1.SetMinVal,"Text")
  settings.Value['maxDistVal']=getProperty(UDF1.SetMaxVal,"Text")
  settings.Value['CamDistVal']=getProperty(UDF1.CamDisEdit,"Text")
  settings.Value['FOVCVal']=getProperty(UDF1.FOVCEdit,"Text")
  settings.Value['FOVFVal']=getProperty(UDF1.FOVFEdit,"Text")
  settings.Value['scrollSpeedVal']=getProperty(UDF1.ScrollSpeedEdit,"Text")
  settings.Value['zoomSpeedVal']=getProperty(UDF1.ZoomSpeedEdit,"Text")
  --settings.Value['pitchMinVal']=getProperty(UDF1.PitchMinEdit,"Text")
 --settings.Value['pitchMaxVal']=getProperty(UDF1.PitchMaxEdit,"Text")
  settings.Value['pitchMinCVal']=getProperty(UDF1.PitchMinCEdit,"Text")
  settings.Value['pitchMaxCVal']=getProperty(UDF1.PitchMaxCEdit,"Text")
  settings.Value['camAngle1Val']=getProperty(UDF1.CameraAngleEdit,"Text")
  --camAngle2Val needs to be neagitve
  settings.Value['camAngle2Val']=getProperty(UDF1.CameraAngle2Edit,"Text")
  settings.Value['tactMinVal']=getProperty(UDF1.SetTactMin,"Text")
  settings.Value['tactMaxVal']=getProperty(UDF1.SetTactMax,"Text")
end


--why tf didnt i combine all the read buttons? tf was i doing?
--i did it for the the first setting and just kinda forgor?
--well id have to change the whole layout now so i think ill leave it



--reads values from game to be show in left most text boxes
function ButtonReadClick(sender)
  setProperty(UDF1.ReadMin,"Text", readFloat(baseAddress .. offsetMin))
  --setProperty(UDF1.ReadMin1,"Text", readFloat(baseAddress .. offsetMinn))
  --removed since its a duplicate value and ill just set both with one
  setProperty(UDF1.ReadMax1,"Text", readFloat(baseAddress .. offsetMax))
  --setProperty(UDF1.ReadMax2,"Text", readFloat(baseAddress .. offsetMaxx))
end

--sets in game values with right minimum text box
function ButtonSetMinClick(sender)
  writeFloat(baseAddress .. offsetMin, getProperty(UDF1.SetMinVal,"Text"))
  --writeFloat(baseAddress .. offsetMinn, getProperty(UDF1.SetMinVal,"Text"))
end

--sets in game values with right maximum text box
function ButtonSetMaxClick(sender)
  writeFloat(baseAddress .. offsetMax, getProperty(UDF1.SetMaxVal,"Text"))
  --writeFloat(baseAddress .. offsetMaxx, getProperty(UDF1.SetMaxVal,"Text"))
end

--sets both text boxes to default values then applies them to game to reset to defaults
function ButtonDefaults(sender)
  UDF1.SetMinVal.Text = '3.5'
  UDF1.SetMaxVal.Text = '12'
  writeFloat(baseAddress .. offsetMin, getProperty(UDF1.SetMinVal,"Text"))
  --writeFloat(baseAddress .. offsetMinn, getProperty(UDF1.SetMinVal,"Text"))
  writeFloat(baseAddress .. offsetMax, getProperty(UDF1.SetMaxVal,"Text"))
  --writeFloat(baseAddress .. offsetMaxx, getProperty(UDF1.SetMaxVal,"Text"))
end

--tactical view, its 2am why
function SetMin1Click(sender)
  writeFloat(baseAddress .. tactMin, getProperty(UDF1.SetTactMin,"Text"))
end

function SetMax1Click(sender)
  writeFloat(baseAddress .. tactMax, getProperty(UDF1.SetTactMax,"Text"))
end

function TactRead(sender)
  setProperty(UDF1.ReadTactMin,"Text", readFloat(baseAddress .. tactMin))
  setProperty(UDF1.ReadTactMax,"Text", readFloat(baseAddress .. tactMax))
end

function DefaultsClick(sender)
  UDF1.SetTactMin.Text = "10"
  UDF1.SetTactMax.Text = "50"
  writeFloat(baseAddress .. tactMin, getProperty(UDF1.SetTactMin,"Text"))
  writeFloat(baseAddress .. tactMax, getProperty(UDF1.SetTactMax,"Text"))
  setProperty(UDF1.ReadTactMin,"Text", readFloat(baseAddress .. tactMin))
  setProperty(UDF1.ReadTactMax,"Text", readFloat(baseAddress .. tactMax))
end


--read camera distance
function ButtonCamDisReadClick(sender)
  setProperty(UDF1.CamDisEdit,"Text", readFloat(baseAddress .. camDis))
end
--write camera distance
function ButtonCamDisSetClick(sender)
  writeFloat(baseAddress .. camDis, getProperty(UDF1.CamDisEdit,"Text"))
end
--reset camera distance
function ButtonCamDisResetClick(sender)
  UDF1.CamDisEdit.Text = '50'
  writeFloat(baseAddress .. camDis, getProperty(UDF1.CamDisEdit,"Text"))
end
--hotkey camera distance
function CamDisHotInc(sender)
  writeFloat(baseAddress .. camDis, getProperty(UDF1.CamDisInc,"Text") + readFloat(baseAddress .. camDis))
  setProperty(UDF1.CamDisEdit,"Text", readFloat(baseAddress .. camDis))
end
hk1=createHotkey(CamDisHotInc, VK_NUMPAD1)
addChangeHotkeyKeysFunctionality(UDF1.cam_dis_inc_hotkey, hk1)
generichotkey_onHotkey(hk1,CamDisHotInc)

function CamDisHotDec(sender)
  writeFloat(baseAddress .. camDis, readFloat(baseAddress .. camDis) - getProperty(UDF1.CamDisInc,"Text"))
  setProperty(UDF1.CamDisEdit,"Text", readFloat(baseAddress .. camDis))
end
hk2=createHotkey(CamDisHotDec, VK_NUMPAD2)
addChangeHotkeyKeysFunctionality(UDF1.cam_dis_dec_hotkey, hk2)
generichotkey_onHotkey(hk2,CamDisHotDec)


--Scroll Speed
function ButtonScrSpdSet(sender)
  writeFloat(baseAddress .. scrollSpeed, getProperty(UDF1.ScrollSpeedEdit,"Text"))
end

function ButtonScrSpdRead(sender)
  setProperty(UDF1.ScrollSpeedEdit,"Text", readFloat(baseAddress .. scrollSpeed))
end

function ButtonScrSpdReset(sender)
  UDF1.ScrollSpeedEdit.Text = ".8"
  writeFloat(baseAddress .. scrollSpeed, getProperty(UDF1.ScrollSpeedEdit,"Text"))
end

function ScrollHotInc(sender)
  writeFloat(baseAddress .. scrollSpeed, getProperty(UDF1.ScrollInc,"Text") + readFloat(baseAddress .. scrollSpeed))
  setProperty(UDF1.ScrollSpeedEdit,"Text", readFloat(baseAddress .. scrollSpeed))
end
hk3=createHotkey(ScrollHotInc, VK_NUMPAD3)
addChangeHotkeyKeysFunctionality(UDF1.scroll_inc_hotkey, hk3)
generichotkey_onHotkey(hk3,ScrollHotInc)

function ScrollHotDec(sender)
  writeFloat(baseAddress .. scrollSpeed, readFloat(baseAddress .. scrollSpeed) - getProperty(UDF1.ScrollInc,"Text"))
  setProperty(UDF1.ScrollSpeedEdit,"Text", readFloat(baseAddress .. scrollSpeed))
end
hk4=createHotkey(ScrollHotDec, VK_NUMPAD4)
addChangeHotkeyKeysFunctionality(UDF1.scroll_dec_hotkey, hk4)
generichotkey_onHotkey(hk4,ScrollHotDec)


--Zoom Speed
function ButtonZmSpdSet(sender)
  writeFloat(baseAddress .. zoomSpeed, getProperty(UDF1.ZoomSpeedEdit,"Text"))
end

function ButtonZmSpdRead(sender)
  setProperty(UDF1.ZoomSpeedEdit,"Text", readFloat(baseAddress .. zoomSpeed))
end

function ButtonZmSpdReset(sender)
  UDF1.ZoomSpeedEdit.Text = ".01"
  writeFloat(baseAddress .. zoomSpeed, getProperty(UDF1.ZoomSpeedEdit,"Text"))
end

function ZoomHotInc(sender)
  writeFloat(baseAddress .. zoomSpeed, getProperty(UDF1.ZoomInc,"Text") + readFloat(baseAddress .. zoomSpeed))
  setProperty(UDF1.ZoomSpeedEdit,"Text", readFloat(baseAddress .. zoomSpeed))
end
hk5=createHotkey(ZoomHotInc, VK_NUMPAD5)
addChangeHotkeyKeysFunctionality(UDF1.zoom_inc_hotkey, hk5)
generichotkey_onHotkey(hk5,ZoomHotInc)

function ZoomHotDec(sender)
  writeFloat(baseAddress .. zoomSpeed, readFloat(baseAddress .. zoomSpeed) - getProperty(UDF1.ZoomInc,"Text"))
  setProperty(UDF1.ZoomSpeedEdit,"Text", readFloat(baseAddress .. zoomSpeed))
end
hk6=createHotkey(ZoomHotDec, VK_NUMPAD6)
addChangeHotkeyKeysFunctionality(UDF1.zoom_dec_hotkey, hk6)
generichotkey_onHotkey(hk6,ZoomHotDec)



--FOV Far
function ButtonFOVFSet(sender)
  writeFloat(baseAddress .. FOVF, getProperty(UDF1.FOVFEdit,"Text"))
end

function ButtonFOVFRead(sender)
  setProperty(UDF1.FOVFEdit,"Text", readFloat(baseAddress .. FOVF))
end

function ButtonFOVFReset(sender)
  UDF1.FOVFEdit.Text = "55"
  writeFloat(baseAddress .. FOVF, getProperty(UDF1.FOVFEdit,"Text"))
end

function FOVFHotInc(sender)
  writeFloat(baseAddress .. FOVF, getProperty(UDF1.FOVFInc,"Text") + readFloat(baseAddress .. FOVF))
  setProperty(UDF1.FOVFEdit,"Text", readFloat(baseAddress .. FOVF))
end
hk7=createHotkey(FOVFHotInc, VK_NUMPAD7)
addChangeHotkeyKeysFunctionality(UDF1.fovf_inc_hotkey, hk7)
generichotkey_onHotkey(hk7,FOVFHotInc)

function FOVFHotDec(sender)
  writeFloat(baseAddress .. FOVF, readFloat(baseAddress .. FOVF) - getProperty(UDF1.FOVFInc,"Text"))
  setProperty(UDF1.FOVFEdit,"Text", readFloat(baseAddress .. FOVF))
end
hk8=createHotkey(FOVFHotDec, VK_NUMPAD8)
addChangeHotkeyKeysFunctionality(UDF1.fovf_dec_hotkey, hk8)
generichotkey_onHotkey(hk8,FOVFHotDec)



--FOV Close
function ButtonFOVCSet(sender)
  writeFloat(baseAddress .. FOVC, getProperty(UDF1.FOVCEdit,"Text"))
end

function ButtonFOVCRead(sender)
  setProperty(UDF1.FOVCEdit,"Text", readFloat(baseAddress .. FOVC))
end

function ButtonFOVCReset(sender)
  UDF1.FOVCEdit.Text = "55"
  writeFloat(baseAddress .. FOVC, getProperty(UDF1.FOVCEdit,"Text"))
end

function FOVCHotInc(sender)
  writeFloat(baseAddress .. FOVC, getProperty(UDF1.FOVCInc,"Text") + readFloat(baseAddress .. FOVC))
  setProperty(UDF1.FOVCEdit,"Text", readFloat(baseAddress .. FOVC))
end
hk9=createHotkey(FOVCHotInc, VK_NUMPAD9)
addChangeHotkeyKeysFunctionality(UDF1.fovc_inc_hotkey, hk9)
generichotkey_onHotkey(hk9,FOVCHotInc)

function FOVCHotDec(sender)
  writeFloat(baseAddress .. FOVC, readFloat(baseAddress .. FOVC) - getProperty(UDF1.FOVCInc,"Text"))
  setProperty(UDF1.FOVCEdit,"Text", readFloat(baseAddress .. FOVC))
end
hk10=createHotkey(FOVCHotDec, VK_CONTROL, VK_NUMPAD1)
addChangeHotkeyKeysFunctionality(UDF1.fovc_dec_hotkey, hk10)
generichotkey_onHotkey(hk10,FOVCHotDec)



--Pitch Min C
function ButtonPchMinCSet(sender)
  writeFloat(baseAddress .. pitchMinC, getProperty(UDF1.PitchMinCEdit,"Text"))
end

function ButtonPchMinCRead(sender)
  setProperty(UDF1.PitchMinCEdit,"Text", readFloat(baseAddress .. pitchMinC))
end

function ButtonPchMinCReset(sender)
  UDF1.PitchMinCEdit.Text = "0.54073804616928"
  writeFloat(baseAddress .. pitchMinC, getProperty(UDF1.PitchMinCEdit,"Text"))
end

function PitchMinCHotInc(sender)
  writeFloat(baseAddress .. pitchMinC, getProperty(UDF1.PitchMinCInc,"Text") + readFloat(baseAddress .. pitchMinC))
  setProperty(UDF1.PitchMinCEdit,"Text", readFloat(baseAddress .. pitchMinC))
end
--hk11=createHotkey(PitchMinCHotInc, VK_CONTROL, VK_NUMPAD2)
--addChangeHotkeyKeysFunctionality(UDF1.pitchminc_inc_hotkey, hk11)
--generichotkey_onHotkey(hk11,PitchMinCHotInc)

function PitchMinCHotDec(sender)
  writeFloat(baseAddress .. pitchMinC, readFloat(baseAddress .. pitchMinC) - getProperty(UDF1.PitchMinCInc,"Text"))
  setProperty(UDF1.PitchMinCEdit,"Text", readFloat(baseAddress .. pitchMinC))
end
--hk12=createHotkey(PitchMinCHotDec, VK_CONTROL, VK_NUMPAD3)
--addChangeHotkeyKeysFunctionality(UDF1.pitchminc_dec_hotkey, hk12)
--generichotkey_onHotkey(hk12,PitchMinCHotDec)




--Pitch Max C
function ButtonPchMaxCSet(sender)
  writeFloat(baseAddress .. pitchMaxC, getProperty(UDF1.PitchMaxCEdit,"Text"))
end

function ButtonPchMaxCRead(sender)
  setProperty(UDF1.PitchMaxCEdit,"Text", readFloat(baseAddress .. pitchMaxC))
end

function ButtonPchMaxCReset(sender)
  UDF1.PitchMaxCEdit.Text = "0.75659638643265"
  writeFloat(baseAddress .. pitchMaxC, getProperty(UDF1.PitchMaxCEdit,"Text"))
end

function PitchMaxCHotInc(sender)
  writeFloat(baseAddress .. pitchMaxC, getProperty(UDF1.PitchMaxCInc,"Text") + readFloat(baseAddress .. pitchMaxC))
  setProperty(UDF1.PitchMaxCEdit,"Text", readFloat(baseAddress .. pitchMaxC))
end
--hk13=createHotkey(PitchMaxCHotInc, VK_CONTROL, VK_NUMPAD4)
--addChangeHotkeyKeysFunctionality(UDF1.pitchmaxc_inc_hotkey, hk13)
--generichotkey_onHotkey(hk13,PitchMaxCHotInc)

function PitchMaxCHotDec(sender)
  writeFloat(baseAddress .. pitchMaxC, readFloat(baseAddress .. pitchMaxC) - getProperty(UDF1.PitchMaxCInc,"Text"))
  setProperty(UDF1.PitchMaxCEdit,"Text", readFloat(baseAddress .. pitchMaxC))
end
--hk14=createHotkey(PitchMaxCHotDec, VK_CONTROL, VK_NUMPAD5)
--addChangeHotkeyKeysFunctionality(UDF1.pitchmaxc_dec_hotkey, hk14)
--generichotkey_onHotkey(hk14,PitchMaxCHotDec)



--Camera Angle
function ButtonCamAngSet(sender)
  writeFloat(baseAddress .. camAngle1, getProperty(UDF1.CameraAngleEdit,"Text"))
end

function ButtonCamAngRead(sender)
  setProperty(UDF1.CameraAngleEdit,"Text", readFloat(baseAddress .. camAngle1))
end

function ButtonCamAngReset(sender)
  UDF1.CameraAngleEdit.Text = "40"
  writeFloat(baseAddress .. camAngle1, getProperty(UDF1.CameraAngleEdit,"Text"))
end

function CamAngHotInc(sender)
  writeFloat(baseAddress .. camAngle1, getProperty(UDF1.CamAngInc,"Text") + readFloat(baseAddress .. camAngle1))
  setProperty(UDF1.CameraAngleEdit,"Text", readFloat(baseAddress .. camAngle1))
end
hk15=createHotkey(CamAngHotInc, VK_CONTROL, VK_NUMPAD6)
addChangeHotkeyKeysFunctionality(UDF1.camang_inc_hotkey, hk15)
generichotkey_onHotkey(hk15,CamAngHotInc)

function CamAngHotDec(sender)
  writeFloat(baseAddress .. camAngle1, readFloat(baseAddress .. camAngle1) - getProperty(UDF1.CamAngInc,"Text"))
  setProperty(UDF1.CameraAngleEdit,"Text", readFloat(baseAddress .. camAngle1))
end
hk16=createHotkey(CanAngHotDec, VK_CONTROL, VK_NUMPAD7)
addChangeHotkeyKeysFunctionality(UDF1.camang_dec_hotkey, hk16)
generichotkey_onHotkey(hk16,CamAngHotDec)




--Camera Angle
function ButtonCamAng2Set(sender)
  writeFloat(baseAddress .. camAngle2, getProperty(UDF1.CameraAngle2Edit,"Text"))
end

function ButtonCamAng2Read(sender)
  setProperty(UDF1.CameraAngle2Edit,"Text", readFloat(baseAddress .. camAngle2))
end

function ButtonCamAng2Reset(sender)
  UDF1.CameraAngle2Edit.Text = "19"
  writeFloat(baseAddress .. camAngle2, getProperty(UDF1.CameraAngle2Edit,"Text"))
end

function CamAng2HotInc(sender)
  writeFloat(baseAddress .. camAngle2, getProperty(UDF1.CamAng2Inc,"Text") + readFloat(baseAddress .. camAngle2))
  setProperty(UDF1.CameraAngle2Edit,"Text", readFloat(baseAddress .. camAngle2))
end
hk17=createHotkey(CamAng2HotInc, VK_CONTROL, VK_NUMPAD8)
addChangeHotkeyKeysFunctionality(UDF1.camang2_inc_hotkey, hk17)
generichotkey_onHotkey(hk17,CamAng2HotInc)

function CamAng2HotDec(sender)
  writeFloat(baseAddress .. camAngle2, readFloat(baseAddress .. camAngle2) - getProperty(UDF1.CamAng2Inc,"Text"))
  setProperty(UDF1.CameraAngle2Edit,"Text", readFloat(baseAddress .. camAngle2))
end
hk18=createHotkey(CamAng2HotDec, VK_CONTROL, VK_NUMPAD9)
addChangeHotkeyKeysFunctionality(UDF1.camang2_dec_hotkey, hk18)
generichotkey_onHotkey(hk18,CamAng2HotDec)


--hide the hud
function HideHUD(sender)
  if (readBytes(baseAddress .. hud) == 0) then
  writeBytes(baseAddress .. hud, "1")
  else
   if (readBytes(baseAddress .. hud) == 1) then
   writeBytes(baseAddress .. hud, "0")
   end
  end
end

--hk19=createHotkey(HideHUD, VK_CONTROL, VK_1)
--addChangeHotkeyKeysFunctionality(UDF1.hud_hotkey, hk19)
--generichotkey_onHotkey(hk19,HideHUD)

local stopZoom = [[
[ENABLE]

aobscanmodule(cbzm,bg3.exe,F3 45 0F 11 4C 24 5C) // should be unique
alloc(newmem,$1000,cbzm)

label(code)
label(return)

newmem:

code:
  //movss [r12+5C],xmm9
  jmp return

cbzm:
  jmp newmem
  nop 2
return:
registersymbol(cbzm)

[DISABLE]

cbzm:
  db F3 45 0F 11 4C 24 5C

unregistersymbol(cbzm)
dealloc(newmem)
]]

local stopUnzoom = [[
[ENABLE]

aobscanmodule(cbzm2,bg3.exe,F3 0F 11 70 5C 0F 28 74 24 20) // should be unique
alloc(newmem,$1000,cbzm2)

label(code)
label(return)

newmem:

code:
  //movss [rax+5C],xmm6
  jmp return

cbzm2:
  jmp newmem
return:
registersymbol(cbzm2)

[DISABLE]
]]

local scriptDisableInfo

function zoomScript(sender)
  if (UDF1.TalkZoom.State==cbChecked)then
   local success1
   local success2
   success1, scriptDisableInfo1 = autoAssemble(stopZoom)
   success2, scriptDisableInfo2 = autoAssemble(stopUnzoom)
   else
   autoAssemble(stopZoom, scriptDisableInfo1)
   autoAssemble(stopUnzoom, scriptDisableInfo2)
   scriptDisableInfo1 = nil
   scriptDisableInfo2 = nil
   end
end

function versionCheck(sender)
  if
    readString(version .. version_offset) == "4.1.1.3636828"
  then
    setProperty(UDF1.VersionCheck,"Caption", readString(version .. version_offset))
    UDF1.VersionCheck.Font.Color=0x00ff00
  else
    setProperty(UDF1.VersionCheck,"Caption", "4.1.1.3636828")
    UDF1.VersionCheck.Font.Color=0x0000ff
  end
end


--Hotkeys, this will be painful wont it, right?
--no just fucking tedious appaerantly i wish i had written this in c#
--and this is too many if statments i couldve simplified



gPlaySoundOnAction=false
--these where throwing an error so they have been commented
--CETrainer.SEPERATOR.Visible=false
UDF1.fixDPI() --remove this if you have already taken care of DPI issues yourself
UDF1.show()
--function AboutClick()
--  showMessage(gAboutText)
--end
--gAboutText=[[Beans]]

function CloseClick()
  hotkeysSettings('save')
  --called by the close button onClick event, and when closing the form
  closeCE()
  return caFree --onClick doesn't care, but onClose would like a result
end
