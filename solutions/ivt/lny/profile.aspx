<%@ Page Language="C#" MasterPageFile="~/mobile_version/MobileMasterPage.master" AutoEventWireup="true" CodeFile="profile.aspx.cs" Inherits="WxQianYue_user_center_profile" Title="无标题页" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <link href="css/profile.css" rel="stylesheet" type="text/css" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="page-profile" id="js_page_profile">
        <div class="wrap">
            <!-- 头部 -->
            <div class="header" node-type="header">
                <a href="javascript:history.go(-1);" target="_blank" class="back">返回</a>
                <span>完善个人资料</span>
            </div>
            <!-- / 头部 -->

            <!-- 表单 -->
            <div class="body" node-type="body">
                <div class="tip">* 完善个人资料，可以赢积分！</div>
                <form node-type="profileForm">
                    <div class="hd">
                        <ul>
                            <li class="name">
                                <em>真实姓名：</em><div class="txt-input"><input name="name" type="text"></div>
                            </li>
                            <li class="nick">
                                <em>昵称：</em><div class="txt-input"><input name="nick" type="text"></div>
                            </li>
                            <li class="sex">
                                <em>性别：</em><span><label><input type="radio" name="sex" value="1"> 男</label> <label><input type="radio" name="sex" value="2"> 女</label> </span>
                            </li>
                            <li class="phone">
                                <em>手机号码：</em><div class="txt-input"><input name="phone" type="text"></div>
                            </li>
                        </ul>
                    </div>
                    <div class="bd">
                        <ul>
                            <li class="birthday">
                                <em>生日：</em> <select><option>北京</option></select> <select><option>北京</option></select> <select><option>北京</option></select>
                            </li>
                            <li class="place">
                                <em>所有地：</em> <select><option>北京</option></select> <select><option>北京</option></select> <select><option>北京</option></select>
                            </li>
                            <li class="detailPlace">
                                <em>所有地：</em> <div class="txt-input"><input type="text"></div>
                            </li>
                        </ul>
                    </div>
                    <div class="ft">
                        <button type="button" class="btn">提交</button>
                    </div>
                </form>
            </div>
            <!-- / 表单 -->
        </div>
    </div>
    <script type="text/javascript" src="js/zepto.js"></script>
    <script type="text/javascript" src="js/profile.js"></script>
</asp:Content>

