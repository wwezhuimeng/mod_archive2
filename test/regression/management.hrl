%%%----------------------------------------------------------------------
%%% File    : management.hrl
%%% Author  : Alexander Tsvyashchenko <ejabberd@ndl.kiev.ua>
%%% Purpose : mod_archive2 collections management commands regression testing
%%%           expected replies
%%% Created : 27 Sep 2009 by Alexander Tsvyashchenko <ejabberd@ndl.kiev.ua>
%%%
%%% mod_archive2, Copyright (C) 2009 Alexander Tsvyashchenko
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with this program; if not, write to the Free Software
%%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
%%% 02111-1307 USA
%%%
%%%----------------------------------------------------------------------

-define(MANAGEMENT_TC1_RETRIEVE_RESULT,
    {received_packet,iq,"result",
     {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
     _,undefined,
     {xmlel,'jabber:client',[],iq,
      [{xmlattr,undefined,from,<<?CLIENTJID>>},
       {xmlattr,undefined,to,
        _},
       {xmlattr,undefined,id,_},
       {xmlattr,undefined,type,<<"result">>}],
      [{xmlel,
        ?NS_ARCHIVING,
        [{?NS_ARCHIVING,
          none}],
        list,[],
        [{xmlel,
          ?NS_ARCHIVING,[],
          chat,
          [{xmlattr,undefined,with,
            <<"juliet@capulet.com/chamber">>},
           {xmlattr,undefined,start,
            <<"1469-07-21T02:56:15.000000Z">>}],
          []},
         {xmlel,'http://jabber.org/protocol/rsm',
          [{'http://jabber.org/protocol/rsm',none}],
          set,[],
          [{xmlel,'http://jabber.org/protocol/rsm',[],first,
            [{xmlattr,undefined,index,<<"0">>}],
            [{xmlcdata,Index}]},
           {xmlel,'http://jabber.org/protocol/rsm',[],last,[],
            [{xmlcdata,Index}]},
           {xmlel,'http://jabber.org/protocol/rsm',[],changed,
            [],
            [{xmlcdata,_}]},
           {xmlel,'http://jabber.org/protocol/rsm',[],count,[],
            [{xmlcdata,<<"1">>}]}]}]}]}}).

-define(MANAGEMENT_TC2_RETRIEVE_RESULT,
    {received_packet,iq,"result",
     {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
     "stanza-" ++ _,undefined,
     {xmlel,'jabber:client',[],iq,
      [{xmlattr,undefined,from,<<?CLIENTJID>>},
       {xmlattr,undefined,to,
        <<?CLIENTJID "/", _/binary>>},
       {xmlattr,undefined,type,<<"result">>},
       {xmlattr,undefined,id,<<"stanza-",_/binary>>}],
      [{xmlel,?NS_ARCHIVING,
        [{?NS_ARCHIVING,none}],
        list,[],[]}]}}).

-define(MANAGEMENT_TC3_RETRIEVE_RESULT,
    {received_packet,iq,"result",
     {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
     _,undefined,
     {xmlel,'jabber:client',[],iq,
      [{xmlattr,undefined,from,<<?CLIENTJID>>},
       {xmlattr,undefined,to,
        _},
       {xmlattr,undefined,id,_},
       {xmlattr,undefined,type,<<"result">>}],
      [{xmlel,'jabber:client',[],chat,
        [{xmlattr,undefined,with,
          <<"juliet@capulet.com/chamber">>},
         {xmlattr,undefined,start,
          <<"1469-07-21T02:56:15.000000Z">>},
         {xmlattr,undefined,subject,<<"She speaks!">>},
         {xmlattr,undefined,thread,<<"damduoeg08">>}],
        [{xmlel,'jabber:client',[],from,
          [{xmlattr,undefined,utc,
            <<"1469-07-21T00:32:29.000000Z">>}],
          [{xmlel,'jabber:client',[],body,[],
            [{xmlcdata,
              <<"Art thou not Romeo, and a Montague?">>}]}]},
         {xmlel,'jabber:client',[],from,
          [{xmlattr,undefined,secs,<<"0">>}],
          [{xmlel,'jabber:client',[],body,[],
            [{xmlcdata,
              <<"Art thou not Romeo, and a Montague?">>}]}]},
         {xmlel,'jabber:client',[],from,
          [{xmlattr,undefined,secs,<<"7">>}],
          [{xmlel,'jabber:client',[],body,[],
            [{xmlcdata,<<"How cam">>},
             {xmlcdata,<<"'">>},
             {xmlcdata,
              <<"st thou hither, tell me, and wherefore?">>}]}]},
         {xmlel,'jabber:client',[],to,
          [{xmlattr,undefined,secs,<<"11">>}],
          [{xmlel,'jabber:client',[],body,[],
            [{xmlcdata,
              <<"Neither, fair saint, if either thee dislike.">>}]}]},
         {xmlel,'http://jabber.org/protocol/rsm',
          [{'http://jabber.org/protocol/rsm',none}],
          set,[],
          [{xmlel,'http://jabber.org/protocol/rsm',[],first,
            [{xmlattr,undefined,index,<<"0">>}],
            [{xmlcdata,_}]},
           {xmlel,'http://jabber.org/protocol/rsm',[],last,[],
            [{xmlcdata,_}]},
           {xmlel,'http://jabber.org/protocol/rsm',[],changed,
            [],
            [{xmlcdata,_}]},
           {xmlel,'http://jabber.org/protocol/rsm',[],count,[],
            [{xmlcdata,<<"4">>}]}]}]}]}}).

-define(MANAGEMENT_TC4_RETRIEVE_RESULT,
    {received_packet,iq,"error",
     {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
     _,undefined,
     {xmlel,'jabber:client',[],iq,
      [{xmlattr,undefined,from,<<?CLIENTJID>>},
       {xmlattr,undefined,to,
        _},
       {xmlattr,undefined,id,_},
       {xmlattr,undefined,type,<<"error">>}],
      [{xmlel,
        ?NS_ARCHIVING,
        [{?NS_ARCHIVING,
          none}],
        retrieve,
        [{xmlattr,undefined,with,
          <<"NOTEXISTING@capulet.com/chamber">>},
         {xmlattr,undefined,start,<<"1469-07-21T02:56:15Z">>}],
        [{xmlel,'http://jabber.org/protocol/rsm',
          [{'http://jabber.org/protocol/rsm',none}],
          set,
          [{xmlattr,undefined,max,<<"100">>}],
          []}]},
       {xmlel,'jabber:client',[],error,
        [{xmlattr,undefined,code,<<"404">>},
         {xmlattr,undefined,type,<<"cancel">>}],
        [{xmlel,'urn:ietf:params:xml:ns:xmpp-stanzas',
          [{'urn:ietf:params:xml:ns:xmpp-stanzas',none}],
          'item-not-found',[],[]}]}]}}).

-define(MANAGEMENT_TC5_UPLOAD_RESULT,
    {received_packet,iq,"result",
        {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
        _,undefined,
        {xmlel,'jabber:client',[],iq,
            [{xmlattr,undefined,from,<<?CLIENTJID>>},
             {xmlattr,undefined,to,
                 _},
             {xmlattr,undefined,id,_},
             {xmlattr,undefined,type,<<"result">>}],
            []}}).

-define(MANAGEMENT_TC5_REMOVE_RESULT,
    {received_packet,iq,"result",
        {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
        _,undefined,
        {xmlel,'jabber:client',[],iq,
            [{xmlattr,undefined,from,<<?CLIENTJID>>},
             {xmlattr,undefined,to,
                 _},
             {xmlattr,undefined,id,_},
             {xmlattr,undefined,type,<<"result">>}],
            []}}).

-define(MANAGEMENT_TC5_RETRIEVE_RESULT,
    {received_packet,iq,"result",
        {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
        _,undefined,
        {xmlel,'jabber:client',[],iq,
            [{xmlattr,undefined,from,<<?CLIENTJID>>},
             {xmlattr,undefined,to,
                 _},
             {xmlattr,undefined,id,_},
             {xmlattr,undefined,type,<<"result">>}],
            [{xmlel,
                 ?NS_ARCHIVING,
                 [{?NS_ARCHIVING,
                   none}],
                 list,[],[]}]}}).

-define(MANAGEMENT_TC5_RETRIEVE_RESULT2,
    {received_packet,iq,"result",
     {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
     _,undefined,
     {xmlel,'jabber:client',[],iq,
      [{xmlattr,undefined,from,<<?CLIENTJID>>},
       {xmlattr,undefined,to,
        _},
       {xmlattr,undefined,id,_},
       {xmlattr,undefined,type,<<"result">>}],
      [{xmlel,
        ?NS_ARCHIVING,
        [{?NS_ARCHIVING,
          none}],
        list,[],
        [{xmlel,
          ?NS_ARCHIVING,[],
          chat,
          [{xmlattr,undefined,with,
            <<"balcony@house.capulet.com">>},
           {xmlattr,undefined,start,
            <<"1469-07-21T03:16:37.000000Z">>}],
          []},
         {xmlel,'http://jabber.org/protocol/rsm',
          [{'http://jabber.org/protocol/rsm',none}],
          set,[],
          [{xmlel,'http://jabber.org/protocol/rsm',[],first,
            [{xmlattr,undefined,index,<<"0">>}],
            [{xmlcdata,Index}]},
           {xmlel,'http://jabber.org/protocol/rsm',[],last,[],
            [{xmlcdata,Index}]},
           {xmlel,'http://jabber.org/protocol/rsm',[],changed,
            [],
            [{xmlcdata,_}]},
           {xmlel,'http://jabber.org/protocol/rsm',[],count,[],
            [{xmlcdata,<<"1">>}]}]}]}]}}).

-define(MANAGEMENT_TC5_REMOVE_RESULT2,
    {received_packet,iq,"result",
        {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
        _,undefined,
        {xmlel,'jabber:client',[],iq,
            [{xmlattr,undefined,from,<<?CLIENTJID>>},
             {xmlattr,undefined,to,
                 _},
             {xmlattr,undefined,id,_},
             {xmlattr,undefined,type,<<"result">>}],
            []}}).

-define(MANAGEMENT_TC5_RETRIEVE_RESULT3,
    {received_packet,iq,"result",
        {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
        _,undefined,
        {xmlel,'jabber:client',[],iq,
            [{xmlattr,undefined,from,<<?CLIENTJID>>},
             {xmlattr,undefined,to,
                 _},
             {xmlattr,undefined,id,_},
             {xmlattr,undefined,type,<<"result">>}],
            [{xmlel,
                 ?NS_ARCHIVING,
                 [{?NS_ARCHIVING,
                   none}],
                 list,[],[]}]}}).

-define(MANAGEMENT_TC6_REMOVE_RESULT,
    {received_packet,iq,"result",
         {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
         _,undefined,
         {xmlel,'jabber:client',[],iq,
             [{xmlattr,undefined,from,<<?CLIENTJID>>},
              {xmlattr,undefined,to,
                  _},
              {xmlattr,undefined,id,_},
              {xmlattr,undefined,type,<<"result">>}],
             []}}).

-define(MANAGEMENT_TC6_RETRIEVE_RESULT,
    {received_packet,iq,"result",
         {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
         _,undefined,
         {xmlel,'jabber:client',[],iq,
             [{xmlattr,undefined,from,<<?CLIENTJID>>},
              {xmlattr,undefined,to,
                  _},
              {xmlattr,undefined,id,_},
              {xmlattr,undefined,type,<<"result">>}],
             [{xmlel,
                  ?NS_ARCHIVING,
                  [{?NS_ARCHIVING,
                    none}],
                  list,[],[]}]}}).

-define(MANAGEMENT_TC7_REMOVE_RESULT,
    {received_packet,iq,"result",
        {<<?CLIENTNAME>>,<<?SERVERHOST>>,undefined},
        _,undefined,
        {xmlel,'jabber:client',[],iq,
            [{xmlattr,undefined,from,<<?CLIENTJID>>},
             {xmlattr,undefined,to,
                 _},
             {xmlattr,undefined,id,_},
             {xmlattr,undefined,type,<<"result">>}],
            []}}).