--[[Example Code
--Generator
local Base = {Tool="Generators",Type="Test"}
local Func = function(self) if(self.Active==1)then Environments.Devices.ManageResources(self) end end
local Data={name="Test",class="test_device_small",In={"energy"},Out={"Testium"},thinkfunc=Func,InUse={10},OutMake={1}}
local Makeup = {name={"Test Fab"},model={"models/SmallBridge/Life Support/sbclimatereg.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
Environments.Devices.CompileDevice(Data,Makeup)

--Storage
local Base = {Tool="Storages",Type="Test"}
local Names = {"Test Wall Storage","Small Test Box"}
local Models = {"models/SmallBridge/Life Support/sbwallcaches05.mdl","models/Items/BoxMRounds.mdl"}
local Data={name="TestStorage",class="testium_storage",storage={"Testium"},Rates={[3000] = "Testium"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
Environments.Devices.CompileStorage(Data,Makeup)

]]