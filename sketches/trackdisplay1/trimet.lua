-- trimet transit tracker 
-- 7536 = 75 southbound @42nd and sumner
-- 11503 = MAX Yellowline southbound @Killingsworth and Interstate.
-- (C) 2013 Donald Delmar Davis, Suspect Devices.
-- THIS IS FREE SOFTWARE, released under Modified BSD (look it up)

http = require("socket.http")

checktime=0
estimates={}
scheduled={}

if io.popen("uname -m"):read("*l") == 'i386' then
  io_output = io.stdout
else
  io_output = '/dev/ttyATH0'
end

io.output(io_output)

-- still trying to figure this out. 
-- from http://lua-users.org/wiki/FiltersSourcesAndSinks
function mysink(chunk,src_err)
  local mycontent=""

  if chunk == nil then
    if src_err then
      -- source reports an error
    else
      -- do something with concatenation of chunks
    end
    return true 
  elseif chunk == "" then
     return true 
  else 
    mycontent=chunk
    -- print(mycontent)

    checktime=string.match(mycontent,'queryTime="(%d+)')
    print (os.date("%d %b %X", string.sub(checktime,1,10)))
    io.write("\254\001",os.date("%d %b %X", string.sub(checktime,1,10)),"\254\192")
    
    i=0
    while true do
      i,j=string.find(mycontent,"<arrival",i)
      if i==nil then 
        break 
      else
        i=i+1;
      end
      arrival=string.sub(mycontent,i,string.find(mycontent,">",j))
      --print(arrival)
      status=string.match(arrival,'status="(%a+)')
      print(status)
      local thetime=0
      local marker="*"
      if string.find(status,'estimated') then
        marker="!"
        thetime=string.match(arrival,'estimated="(%d+)')
      else
        thetime=string.match(arrival,'scheduled="(%d+)')
      end
      --irb(main):011:0> Time.at('1368871373735'[0,10].to_i)
      --=> 2013-05-18 03:02:53 -0700
      local timerep=os.date("%c", string.sub(thetime,1,10) )
      print(os.date("%c", os.difftime(os.time(), (string.sub(thetime,1,10)))))
      --print(timerep)
      print("----------------------")
      --print(status.."("..thetime..")="..timerep  )
      --io.write(" ".. marker .. os.date("%I:%M", string.sub(thetime,1,10) ) .." ")
    end
    return true
  end
  -- in case of error
  return nil, err
end

--- Delay for a number of seconds.
-- @param delay Number of seconds
function delay_s(delay)
    delay = delay or 1
    local time_to = os.time() + delay
    while os.time() < time_to do end
end

while true do
  http.request{
    url="http://developer.trimet.org/ws/V1/arrivals?locIDs=11503&appID=EC36A740E55BB5A803BB2602B";
    sink=mysink;
  }
  io.flush()
  delay_s(7)
end
