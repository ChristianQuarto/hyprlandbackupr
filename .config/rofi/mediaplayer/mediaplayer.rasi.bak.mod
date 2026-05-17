configuration {
    show-icons: false;
}

@import "~/.config/rofi/colors/shared.rasi"

window {
    transparency:     "real";
    location:         north;
    anchor:           north;
    fullscreen:       false;
    width:            400px;

    x-offset:         0px;
    y-offset:         -3px;
    border:           2px solid;
    border-radius:    20px;
    border-color:     @selected;
    background-color: @background;
}

mainbox {
    spacing:          0px;
    padding:          0px;
    background-color: transparent;
    children:         [ "message", "listview" ];
}

message {
    padding:          14px 16px;
    margin:           0px;
    border-radius:    18px 18px 0px 0px;
    background-color: @background-alt;
    background-image: url("~/.cache/rofi-mediaplayer/cover.png", width);
    text-color:       @foreground;
}

textbox {
    background-color: rgba(0,0,0,0.6);
    text-color:       white;
    vertical-align:   1.0;
    horizontal-align: 0.0;
    font:             "JetBrainsMono Nerd Font 11";
    padding:          10px;
    border-radius:    0px 0px 0px 0px;
}

listview {
    columns:          5;
    lines:            1;
    cycle:            true;
    scrollbar:        false;
    fixed-height:     true;
    fixed-columns:    true;
    spacing:          8px;
    padding:          12px;
    background-color: @background;
    border-radius:    0px 0px 18px 18px;
}

element {
    padding:          14px 0px;
    border-radius:    10px;
    background-color: @background-alt;
    text-color:       @foreground;
    cursor:           pointer;
    orientation:      vertical;
}

element-text {
    background-color: transparent;
    text-color:       inherit;
    vertical-align:   0.5;
    horizontal-align: 0.5;
    font:             "JetBrainsMono Nerd Font 20";
}

element selected.normal {
    background-color: @selected;
    text-color:       @background;
}
