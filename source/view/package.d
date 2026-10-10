// This package contains custom Widgets, they can be easily used in other projects
module view;

public import view.memorydrawable;
public import view.numberbox;
public import view.preview;
public import view.statewidget;
public import view.colordrawbufex;
public import view.rectutils;
public import view.logline;
public import view.messagebox;
public import view.stateframelayout;

import dlangui;
import dlangui.widgets.metadata;

shared static this()
{
    mixin(registerWidgetMetadataClass!IntBox);
    mixin(registerWidgetMetadataClass!FloatBox);
}
//mixin(registerWidgets!("__gshared static this", IntBox, FloatBox)());