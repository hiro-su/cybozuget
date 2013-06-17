# coding: utf-8

module CybozuGet

class API
  def initialize(user, pass, api_base)
    @user = user
    @pass = pass
    @api_base = api_base
  end

  def replace(text)
    text.gsub(/soap:/,"soap")
    .gsub(/schedule:/,"schedule")
    .gsub(/base:/,"base")
  end
  
  def doRequest(client,api,data,header)
    res = client.post(api, data, header)
    REXML::Document.new(replace(res.body))
  end
  
  def api_base(params,api_name)
    <<-"EOS"
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
  xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Header>
    <Action
    SOAP-ENV:mustUnderstand="1"
    xmlns="http://schemas.xmlsoap.org/ws/2003/03/addressing">
      #{api_name}
    </Action>
    <Security
    xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility"
    SOAP-ENV:mustUnderstand="1"
    xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext">
      <UsernameToken wsu:Id="id">
        <Username>#{@user}</Username>
        <Password>#{@pass}</Password>
      </UsernameToken>
    </Security>
    <Timestamp
    SOAP-ENV:mustUnderstand="1"
    Id="id"
    xmlns="http://schemas.xmlsoap.org/ws/2002/07/utility">
      <Created>2037-08-12T14:45:00Z</Created>
      <Expires>2037-08-12T14:45:00Z</Expires>
    </Timestamp>
    <Locale>jp</Locale>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <#{api_name}>
      #{params}
    </#{api_name}>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
    EOS
  end
  
  def get_uid(client, user_name)
    user_id = ""
    user = {}
  
    get_user_id = <<-"EOS"
    <parameters>
      <login_name>#{user_name}</login_name>
    </parameters>
    EOS

    data = api_base(get_user_id,"BaseGetUsersByLoginName")
  
    header = {
      'Content_length' => data.length.to_s,
      'Content-Type' => "text/xml",
    }
  
    base_api_path = "#{@api_base}/cbpapi/base/api"
    doc = doRequest(client, base_api_path, data, header)
    uid_path = "/soapEnvelope/soapBody/baseBaseGetUsersByLoginNameResponse/returns"
    doc.elements.each(uid_path) do |elem|
      user_id = elem.elements["user"].attributes["key"]
      name = elem.elements["user"].attributes["name"]
      reading = elem.elements["user"].attributes["reading"]
      email = elem.elements["user"].attributes["email"]
      user = {
        "user_id" => user_id,
        "name" => name,
        "reading" => reading,
        "email" => email
      }
    end
    user
  rescue => ex
    raise ex
  end
  
  def get_schedule(client, uid, stime, etime)
    get_schedule = <<-"EOS"
    <parameters start="#{stime}" end="#{etime}">
      <user xmlns="" id="#{uid}"></user>
    </parameters>
    EOS
  
    data = api_base(get_schedule,"ScheduleGetEventsByTarget")
  
    header = {
      'Content_length' => data.length.to_s,
      'Content-Type' => "text/xml",
    }
  
    schedule_api_path = "#{@api_base}/cbpapi/schedule/api"
    doRequest(client, schedule_api_path, data, header)
  rescue => ex
    raise ex
  end

  def create_time(opts={})
    start_time = opts[:start_time]
    end_time = opts[:end_time]
    day = opts[:day]
    week = opts[:week]
    init_time_format = "%Y-%m-%d 00:00:00"
    time_format = "%Y-%m-%dT%H:%M:%SZ"
    one_day = 86400

    if start_time.nil? && end_time.nil?
      offset_time = Time.at(Time.parse(Time.now.strftime(init_time_format)).to_i).utc
      if !week.nil?
        week = week.to_i
        stime = format_time(offset_time, time_format, week-(week-1), :*)
        etime = format_time(offset_time, time_format, one_day*(week+1)-1, :+)
      elsif day.nil?
        stime = offset_time.strftime(time_format)
        etime = format_time(offset_time, time_format, one_day-1, :+)
      else
        day = day.to_i
        stime = format_time(offset_time, time_format, one_day*day, :+)
        etime = format_time(offset_time, time_format, one_day*(day+1)-1, :+)
      end
    elsif end_time.nil?
      offset_time = Time.parse(start_time)
      stime = offset_time.utc.strftime(time_format)
      etime = format_time(offset_time, time_format, one_day-1, :+)
    elsif start_time.nil?
      puts "please set start time -s '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
      exit
    else
      stime = Time.parse(start_time).utc.strftime(time_format)
      etime = format_time(Time.parse(end_time), time_format, one_day-1, :+)
    end
    [stime, etime]
  end

  private

  def format_time(offset_time, format, value, method)
    Time.at(offset_time.to_i.send(method, value)).utc.strftime(format)
  end
end

end
