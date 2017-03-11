-define(DEBUG(Msg, Args), lager:log(debug,[{module, ?MODULE},{line, ?LINE}],Msg, Args)).
-define(INFO(Msg, Args), lager:log(info,[{module, ?MODULE},{line, ?LINE}],Msg, Args)).
-define(NOTICE(Msg, Args), lager:log(notice,[{module, ?MODULE},{line, ?LINE}],Msg, Args)).
-define(WARNING(Msg, Args), lager:log(warning,[{module, ?MODULE},{line, ?LINE}],Msg, Args)).
-define(ERROR(Msg, Args), lager:log(error,[{module, ?MODULE},{line, ?LINE}],Msg, Args)).
-define(CRITICAL(Msg, Args), lager:log(critical,[{module, ?MODULE},{line, ?LINE}],Msg, Args)).

-record(resource, {start_s,start_us,body_bin,user_id,device_id,facebook_id,locale,time_zone,contents,error_code,error_message,throw,method,module}).