<GameProjectFile>
  <PropertyGroup Type="Layer" Name="Login" ID="73623d3d-d9dd-4a77-bf6b-e07f9c5ba57c" Version="2.0.5.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="LayerLogin" FrameEvent="" Tag="18" ctype="LayerObjectData">
        <Position X="0.0000" Y="0.0000" />
        <Scale ScaleX="1.0000" ScaleY="1.0000" />
        <AnchorPoint />
        <CColor A="255" R="255" G="255" B="255" />
        <Size X="640.0000" Y="960.0000" />
        <PrePosition X="0.0000" Y="0.0000" />
        <PreSize X="0.0000" Y="0.0000" />
        <Children>
          <NodeObjectData Name="Sprite_background" ActionTag="758175792" FrameEvent="" Tag="34" ObjectIndex="7" ctype="SpriteObjectData">
            <Position X="320.0000" Y="480.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <CColor A="255" R="255" G="255" B="255" />
            <Size X="640.0000" Y="960.0000" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="Normal" Path="Picture/background_01.png" />
          </NodeObjectData>
          <NodeObjectData Name="Image_gray" ActionTag="308420054" FrameEvent="" Tag="20" ObjectIndex="1" Scale9Enable="True" LeftEage="23" RightEage="23" TopEage="15" BottomEage="15" Scale9OriginX="9" Scale9OriginY="15" Scale9Width="14" Scale9Height="18" ctype="ImageViewObjectData">
            <Position X="0.0000" Y="0.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <AnchorPoint />
            <CColor A="255" R="255" G="255" B="255" />
            <Size X="640.0000" Y="960.0000" />
            <PrePosition X="0.0000" Y="0.0000" />
            <PreSize X="1.0000" Y="1.0000" />
            <FileData Type="Normal" Path="Picture/gray_01.png" />
          </NodeObjectData>
          <NodeObjectData Name="Panel_frame" ActionTag="1645495557" FrameEvent="" Tag="9" ObjectIndex="2" TouchEnable="True" BackColorAlpha="102" ColorAngle="90.0000" Scale9Enable="True" LeftEage="88" RightEage="88" TopEage="88" BottomEage="88" Scale9OriginX="88" Scale9OriginY="88" Scale9Width="2" Scale9Height="2" ctype="PanelObjectData">
            <Position X="320.0000" Y="920.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <Size X="450.0000" Y="350.0000" />
            <PrePosition X="0.5000" Y="0.9583" />
            <PreSize X="0.7031" Y="0.3646" />
            <Children>
              <NodeObjectData Name="Sprite_title" ActionTag="-1708325745" FrameEvent="" Tag="10" ObjectIndex="2" ctype="SpriteObjectData">
                <Position X="225.0000" Y="340.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="282.0000" Y="62.0000" />
                <PrePosition X="0.5000" Y="0.9714" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="Picture/text_login_game.png" />
              </NodeObjectData>
              <NodeObjectData Name="Sprite_account" ActionTag="-503331058" FrameEvent="" Tag="11" ObjectIndex="3" ctype="SpriteObjectData">
                <Position X="225.0000" Y="260.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="361.0000" Y="56.0000" />
                <PrePosition X="0.5000" Y="0.7429" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="Picture/account_bg.png" />
              </NodeObjectData>
              <NodeObjectData Name="Sprite_password" ActionTag="-1859940203" FrameEvent="" Tag="13" ObjectIndex="5" ctype="SpriteObjectData">
                <Position X="225.0000" Y="190.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="361.0000" Y="56.0000" />
                <PrePosition X="0.5000" Y="0.5429" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="Picture/password__bg_01.png" />
              </NodeObjectData>
              <NodeObjectData Name="TextField_account" ActionTag="-1682823766" FrameEvent="" Tag="14" ObjectIndex="1" TouchEnable="True" FontSize="24" IsCustomSize="True" LabelText="" PlaceHolderText="账号" MaxLengthEnable="True" MaxLengthText="7" ctype="TextFieldObjectData">
                <Position X="210.0000" Y="260.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="180.0000" Y="24.0000" />
                <PrePosition X="0.4667" Y="0.7429" />
                <PreSize X="0.4018" Y="0.0635" />
              </NodeObjectData>
              <NodeObjectData Name="TextField_password" ActionTag="141083152" FrameEvent="" Tag="15" ObjectIndex="2" TouchEnable="True" FontSize="24" IsCustomSize="True" LabelText="" PlaceHolderText="密码" MaxLengthEnable="True" MaxLengthText="6" PasswordEnable="True" ctype="TextFieldObjectData">
                <Position X="210.0000" Y="190.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="180.0000" Y="24.0000" />
                <PrePosition X="0.4667" Y="0.5429" />
                <PreSize X="0.4018" Y="0.0635" />
              </NodeObjectData>
              <NodeObjectData Name="CheckBox_remember" ActionTag="-1526168873" FrameEvent="" Tag="16" ObjectIndex="1" TouchEnable="True" CheckedState="True" ctype="CheckBoxObjectData">
                <Position X="80.0000" Y="120.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="40.0000" Y="40.0000" />
                <PrePosition X="0.1778" Y="0.3429" />
                <PreSize X="0.0000" Y="0.0000" />
                <NormalBackFileData Type="Default" Path="Default/CheckBox_Normal.png" />
                <PressedBackFileData Type="Default" Path="Default/CheckBox_Press.png" />
                <DisableBackFileData Type="Default" Path="Default/CheckBox_Disable.png" />
                <NodeNormalFileData Type="Default" Path="Default/CheckBoxNode_Normal.png" />
                <NodeDisableFileData Type="Default" Path="Default/CheckBoxNode_Disable.png" />
              </NodeObjectData>
              <NodeObjectData Name="Sprite_remember_password" ActionTag="-1657779172" FrameEvent="" Tag="17" ObjectIndex="6" ctype="SpriteObjectData">
                <Position X="150.0000" Y="120.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="70.0000" Y="17.0000" />
                <PrePosition X="0.3333" Y="0.3429" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="Picture/text_remember_password.png" />
              </NodeObjectData>
              <NodeObjectData Name="Button_register" ActionTag="1730060989" FrameEvent="" Tag="18" ObjectIndex="1" TouchEnable="True" FontSize="14" ButtonText="" Scale9Width="127" Scale9Height="53" ctype="ButtonObjectData">
                <Position X="129.9999" Y="50.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="127.0000" Y="53.0000" />
                <PrePosition X="0.2889" Y="0.1429" />
                <PreSize X="0.0000" Y="0.0000" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="Picture/button_register_01.png" />
                <PressedFileData Type="Normal" Path="Picture/button_register_01.png" />
                <NormalFileData Type="Normal" Path="Picture/button_register_01.png" />
              </NodeObjectData>
              <NodeObjectData Name="Button_login" ActionTag="144338115" FrameEvent="" Tag="19" ObjectIndex="2" TouchEnable="True" FontSize="14" ButtonText="" Scale9Width="127" Scale9Height="53" ctype="ButtonObjectData">
                <Position X="320.0000" Y="50.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="127.0000" Y="53.0000" />
                <PrePosition X="0.7111" Y="0.1429" />
                <PreSize X="0.0000" Y="0.0000" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="Picture/button_login_01.png" />
                <PressedFileData Type="Normal" Path="Picture/button_login_01.png" />
                <NormalFileData Type="Normal" Path="Picture/button_login_01.png" />
              </NodeObjectData>
            </Children>
            <FileData Type="Normal" Path="Picture/frame_01.png" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </NodeObjectData>
          <NodeObjectData Name="Button_entMap" ActionTag="63634534" FrameEvent="" Tag="209" ObjectIndex="5" TouchEnable="True" FontSize="14" ButtonText="地图编辑器" Scale9Width="46" Scale9Height="36" ctype="ButtonObjectData">
            <Position X="322.1428" Y="362.8571" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <CColor A="255" R="255" G="255" B="255" />
            <Size X="70.0000" Y="36.0000" />
            <PrePosition X="0.0000" Y="0.0000" />
            <PreSize X="0.0000" Y="0.0000" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="Default" Path="Default/Button_Disable.png" />
            <PressedFileData Type="Default" Path="Default/Button_Press.png" />
            <NormalFileData Type="Default" Path="Default/Button_Normal.png" />
          </NodeObjectData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameProjectFile>