xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/XOperaApp/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/XOperaApp/config" at "config.xqm";

declare variable $app:plays as node()* := collection('/db/shakespeare')//PLAY;

declare function local:nav-links($play) as node()*{
    if ($play) then (
        <li><a href="index.html?play={encode-for-uri($play)}">Go to summary</a></li>,
        <li class="divider"></li>
    ) else(),
    for $name in $app:plays//PLAYSUBT
    where $name != $play
    return <li><a href="index.html?play={encode-for-uri($name)}">{$name}</a></li>
};

declare %templates:wrap
 function app:navigator($node as node(), $model as map(*)) {
   let $play := xs:string(request:get-parameter("play", ""))
   return 
    <ul class="nav navbar-nav">
        <li class="dropdown">
            <a href="index.html" class="dropdown-toggle" data-toggle="dropdown">{
                if ($play) then $play else 'Choose play'
            } <b class="caret"></b></a>
            <ul class="dropdown-menu">
            {local:nav-links($play)}
            </ul>
        </li>
    </ul>
};

declare function local:display-home() {
    <div class="jumbotron">
            <div class="container">
                <h1>Welcome to XOpera!</h1>
                <p>Just choose a play from the above navigator menu to start!</p>
            </div>
    </div>
};

declare function local:display-act($play, $desired_act) {
  let $act := $play//ACT[position() = xs:int($desired_act)] 
  return
    <div class="container">
        <h4>{$act/TITLE/text()}</h4>
        <div class="accordion panel-group" id="accordion_prologue">
            <div class="accordion-group panel panel-default">
                <div class="accordion-heading panel-heading">
                  <h4 class="panel-title">
                      <a class="accordion-toggle collapsed" 
                        data-toggle="collapse" 
                        data-parent="#accordion_prologue"
                        href="#collapse_prologue">
                        Prologue
                      </a>
                  </h4>
                </div>
                <div id="collapse_prologue" 
                    class="accordion-body collapse panel-body">
                    <div class="accordion-inner">
                    {local:display-speech($act/PROLOGUE/SPEECH)}
                    </div>
                </div>
            </div>
        </div>
        <div class="accordion panel-group" id="accordion_personas">
            <div class="accordion-group panel panel-default">
                <div class="accordion-heading panel-heading">
                  <h4 class="panel-title">
                      <a class="accordion-toggle collapsed" 
                        data-toggle="collapse" 
                        data-parent="#accordion_personas"
                        href="#collapse_personas">
                        Speakers
                      </a>
                  </h4>
                </div>
                <div id="collapse_personas" 
                    class="accordion-body collapse panel-body">
                    <div class="accordion-inner">
                    {
                    let $speakers := distinct-values($act//SPEAKER/text())
                    return for $speaker in $speakers 
                            let $params := concat('play=',encode-for-uri($play//PLAYSUBT/text()), 
                                '&amp;', 'char=',encode-for-uri($speaker),
                                '&amp;', 'act=',$desired_act)
                            return <div class="row">
                                    <a href="index.html?{$params}">
                                            <strong>{$speaker}</strong>
                                    </a>
                                </div>
                    }
                    </div>
                </div>
            </div>
       </div>
       <div class="accordion panel-group" id="accordion_outline">
            <div class="accordion-group panel panel-default">
                <div class="accordion-heading panel-heading">
                  <h4 class="panel-title">
                      <a class="accordion-toggle collapsed" 
                        data-toggle="collapse" 
                        data-parent="#accordion_outline"
                        href="#collapse_outline">
                        Outline
                      </a>
                  </h4>
                </div>
                <div id="collapse_outline" 
                    class="accordion-body collapse panel-body">
                    <div class="accordion-inner">
                        <ul>
                        {
                        for $scene at $i in $act/SCENE 
                         let $params := concat('play=',encode-for-uri($play//PLAYSUBT/text()),
                                '&amp;', 'act=',$desired_act,
                                '&amp;', 'scene=',$i) return
                            <li>
                                <a href="index.html?{$params}">
                                {$scene/TITLE/substring-before(text(), '.')}
                                </a>
                            </li>
                        }
                        </ul>
                    </div>
                </div>
            </div>
       </div>
    </div>
};

declare function local:display-scene($play, $desired_act, $desired_scene) {
  let $act := $play//ACT[position() = xs:int($desired_act)],
    $scene := $act/SCENE[position() = xs:int($desired_scene)],
    $act_params := concat('play=',encode-for-uri($play//PLAYSUBT/text()),
                                '&amp;', 'act=',$desired_act)
  return
    <div class="container">
        <h4><a href="index?{$act_params}">{$act/TITLE/text()}</a> - {$scene/TITLE/substring-before(text(), '.')}</h4>
        <div class="panel-group">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="panel-title">Description</h4>
                </div>
                <div class="panel-body">
                   {$scene/TITLE/substring-after(text(), '.')}
                </div>
            </div>
        </div>
        <div class="accordion panel-group" id="accordion_personas">
            <div class="accordion-group panel panel-default">
                <div class="accordion-heading panel-heading">
                  <h4 class="panel-title">
                      <a class="accordion-toggle collapsed" 
                        data-toggle="collapse" 
                        data-parent="#accordion_personas"
                        href="#collapse_personas">
                        Speakers
                      </a>
                  </h4>
                </div>
                <div id="collapse_personas" 
                    class="accordion-body collapse panel-body">
                    <div class="accordion-inner">
                    {
                    let $speakers := distinct-values($scene//SPEAKER/text())
                    return for $speaker in $speakers 
                            let $params := concat('play=',encode-for-uri($play//PLAYSUBT/text()), 
                                '&amp;', 'char=',encode-for-uri($speaker),
                                '&amp;', 'act=',$desired_act,
                                '&amp;', 'scene=',$desired_scene)
                            return <div class="row">
                                    <a href="index.html?{$params}">
                                        <strong>{$speaker}</strong>
                                    </a>
                                </div>
                    }
                    </div>
                </div>
            </div>
       </div>
       <div class="accordion panel-group" id="accordion_outline">
            <div class="accordion-group panel panel-default">
                <div class="accordion-heading panel-heading">
                  <h4 class="panel-title">
                      <a class="accordion-toggle collapsed" 
                        data-toggle="collapse" 
                        data-parent="#accordion_outline"
                        href="#collapse_outline">
                        Content
                      </a>
                  </h4>
                </div>
                <div id="collapse_outline" 
                    class="accordion-body collapse panel-body">
                    <div class="accordion-inner">
                        {
                        for $elem in $scene/* return
                            if($elem/name() = 'SPEECH') then local:display-speech($elem)
                            else if($elem/name() = 'STAGEDIR') then
                                <p class="stagedir">{$elem/text()}</p>
                                else ()
                        }
                    </div>
                </div>
            </div>
       </div>
    </div>
};

declare function local:display-summary($play) {
   <div class="container">
    <h1>{$play/TITLE/text()}</h1>
    <h4 style="padding-left:2em">by Shakespeare</h4>

    <div class="panel-group">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4 class="panel-title">Setting</h4>
            </div>
            <div class="panel-body">
                {$play/SCNDESCR/text()}
            </div>
        </div>
    </div>
    <div class="accordion panel-group" id="accordion_personas">
        <div class="accordion-group panel panel-default">
            <div class="accordion-heading panel-heading">
              <h4 class="panel-title">
                  <a class="accordion-toggle collapsed" 
                    data-toggle="collapse" 
                    data-parent="#accordion_personas"
                    href="#collapse_personas">
                    {$play/PERSONAE/TITLE/text()}
                  </a>
              </h4>
            </div>
            <div id="collapse_personas" 
                class="accordion-body collapse panel-body">
                <div class="accordion-inner">
                {
                let $personas := $play/PERSONAE//PERSONA,
                    $speakers := distinct-values($play//SPEECH/SPEAKER/text()),
                    $map := map:new(
                        for $speaker in $speakers 
                        return  
                            map:entry(local:get-closest($speaker, $personas), $speaker)
                    )
                return for $persona in $personas 
                        let $char := map:get($map, $persona/text()),
                            $params := concat('play=',encode-for-uri($play//PLAYSUBT/text()), 
                            '&amp;', 'char=',encode-for-uri($char))
                        return
                        <div class="row">
                            <div class="col-sm-6">
                                {
                                if($char) then 
                                    <a href="index.html?{$params}">
                                        <strong>{$persona/text()}</strong>
                                    </a>
                                else <strong>{$persona/text()}</strong>
                                }
                            </div>
                            <div class="col-sm-6">{$persona/following-sibling::GRPDESCR/text()}</div>
                        </div>
                }
                </div>
            </div>
        </div>
   </div>
   <div class="accordion panel-group" id="accordion_outline">
        <div class="accordion-group panel panel-default">
            <div class="accordion-heading panel-heading">
              <h4 class="panel-title">
                  <a class="accordion-toggle collapsed" 
                    data-toggle="collapse" 
                    data-parent="#accordion_outline"
                    href="#collapse_outline">
                    Outline
                  </a>
              </h4>
            </div>
            <div id="collapse_outline" 
                class="accordion-body collapse panel-body">
                <div class="accordion-inner">
                    <ul>
                    {
                    for $act at $i in $play//ACT
                        let $params := concat('play=',encode-for-uri($play//PLAYSUBT/text()),
                                '&amp;', 'act=',$i) return
                        <li><a href="index.html?{$params}">{$act/TITLE/text()}</a>
                            <ul>
                            {
                            for $scene at $j in $act/SCENE return
                                <li>
                                    <a href="index.html?{concat($params, '&amp;', 'scene=', $j)}">
                                        {$scene/TITLE/substring-before(text(), '.')}
                                    </a>
                                </li>
                            }
                            </ul>
                        </li>
                    }
                    </ul>
                </div>
            </div>
        </div>
   </div>
   </div>
};

declare function local:display-part($play as node(), $char as xs:string, $desired_act as xs:string, $desired_scene as xs:string){
   <div class="accordion panel-group" id="accordion_acts">
    {
    let $acts := if ($desired_act) then 
                    $play//ACT[position() = xs:int($desired_act)] 
                 else $play//ACT[descendant::SPEAKER/text() = $char]
    for $act at $i in $acts
    let $params := concat('play=',encode-for-uri($play//PLAYSUBT/text()),
                    '&amp;', 'act=', index-of($play//ACT, $act)) return
        <div class="accordion-group panel panel-default">
            <div class="accordion-heading panel-heading">
              <h4 class="panel-title">
                <a href="index.html?{$params}">{$act/TITLE/text()}</a>
                  <a class="accordion-toggle {if (count($acts)>1) then 'collapsed' else ()}" 
                    data-toggle="collapse" 
                    data-parent="#accordion_acts"
                    href="#collapse_act{$i}">
                  </a>
              </h4>
            </div>
            <div id="collapse_act{$i}" 
                class="accordion-body collapse panel-body {if (count($acts)>1) then () else 'in'}">
                <div class="accordion-inner">
                    <div class="accordion panel-group" id="accordion_act{$i}">
                    { 
                    let $scenes := if ($desired_scene) then 
                                        $act/SCENE[position() = xs:int($desired_scene)] 
                                   else $act/SCENE[descendant::SPEAKER/text() = $char]
                    for $scene at $j in $scenes return
                        let $full_params := concat($params, 
                            '&amp;', 'scene=', index-of($act/SCENE, $scene)) return
                        local:display-scene($char, $scene, $i, $j, $full_params, boolean(count($scenes)>1))
                    }
                    </div>
                </div>
            </div>
        </div>
    }
   </div>
};

declare function local:display-scene($char as xs:string, $scene as node(), $act_no as xs:int, $scene_no as xs:int, $url_params as xs:string, $closed as xs:boolean){
   <div class="accordion-group panel panel-default">
    <div class="accordion-heading panel-heading">
        <h4 class="panel-title">
          <a href="index.html?{$url_params}">{$scene/TITLE/substring-before(text(), '.')}</a>
          <a class="accordion-toggle {if ($closed) then 'collapsed' else ()}" 
              data-toggle="collapse" 
              data-parent="#accordion_act{$act_no}" 
              href="#collapse_act{$act_no}_scene{$scene_no}">
          </a>
        </h4>
    </div>
    <div id="collapse_act{$act_no}_scene{$scene_no}" 
        class="accordion-body panel-body collapse {if ($closed) then () else 'in'}">
      <div class="accordion-inner">
        <h5 class="scene-desc">{$scene/TITLE/substring-after(text(), '.')}</h5><br/>
        {local:display-speech($scene//SPEECH[SPEAKER/text() = $char])}
      </div>
    </div>
   </div>
};

declare function local:display-speech($speech_list as node()*){
   for $speech in $speech_list
   return <div class="row speech">
            <div class="col-sm-3 col-md-2"><p class="speech-speaker text-bold">{
                if ($speech/SPEAKER/text()) then
                    $speech/SPEAKER/text()
                else 'NARRATOR'
            }</p></div>
            <div class="col-sm-9 col-md-10">{
                for $line in $speech/LINE
                return <p class="speech-line">{$line/text()}</p>
            }</div>
        </div>
};

declare function local:get-closest($speaker as xs:string, $personas as node()*){
    let $full := $personas[text() = $speaker] return
    if ($full) then $full/text()
                else let $beginning := $personas[substring-before(text(), ',') = $speaker]
                     return if ($beginning) then $beginning/text()
                            else ('')
};

declare %templates:wrap
 function app:main($node as node(), $model as map(*)) {
   let  $play := xs:string(request:get-parameter("play", "")),
        $act := xs:string(request:get-parameter("act", "")),
        $scene := xs:string(request:get-parameter("scene", "")),
        $char := xs:string(request:get-parameter("char", ""))
   return
        if($play) then
            let $play_node := $app:plays[descendant::PLAYSUBT/text() = $play]
            return if ($char) then
                        local:display-part($play_node, $char, $act, $scene)
                    else if ($act) then
                            if ($scene) then
                                local:display-scene($play_node, $act, $scene)
                            else (local:display-act($play_node, $act))
                        else local:display-summary($play_node)
        else local:display-home()
};