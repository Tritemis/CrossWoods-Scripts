local chatservice = require(game.ServerScriptService.ChatServiceRunner.ChatService);
chatservice.InternalApplyRobloxFilterNewAPI=function(self,sp,mes,textfilcon)
	return true,false,mes 
end;
chatservice.InternalApplyRobloxFilter=function(self,sp,mes,toname) 
	return mes 
end