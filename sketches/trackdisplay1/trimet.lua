-- trimet transit tracker 
-- 7536 = 75 southbound @42nd and sumner
-- 11503 = MAX Yellowline southbound @Killingsworth and Interstate.
-- (C) 2013 Donald Delmar Davis, Suspect Devices.
-- THIS IS FREE SOFTWARE, released under Modified BSD (look it up)

http = require("socket.http")

checktime=0
estimates={}
scheduled={}

-- I want to do a list comprehension here
current_platform = io.popen("uname -m"):read("*l")
if current_platform == 'i386' then
  io_output = io.stdout
elseif current_platform == 'x86_64' then
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
      status=string.match(arrival,'status="(%a+)')
      local thetime=0
      local marker="~"
      local minutes_till = ''
      if string.find(status,'estimated') then
        marker=""
        thetime=string.match(arrival,'estimated="(%d+)')
      else
        thetime=string.match(arrival,'scheduled="(%d+)')
      end
      thetime = string.sub(thetime,1,10)
      local timerep=os.date("%c", thetime )
      print(status.."("..thetime..")="..timerep  )

      local delta = (os.difftime(thetime, os.time()) / 60)
      print("delta: "..delta)
      if delta > 60 then
        marker = ''
        minutes_till = '(z_z)'
      elseif delta < 1 then
        minutes_till = 'Due'
      else
        minutes_till = string.format("%.0f min", delta)
      end
      print("minutes_till: "..minutes_till)
      io.write(marker .. minutes_till .." ")
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
