xquery version "3.0";

(:doc('music/BeetAnGeSample.xml')//work-title/text(),:)
(:doc('music/BeetAnGeSample.xml')//creator[@type='composer']/text(),:)
(:doc('music/BeetAnGeSample.xml')//creator[@type='lyricist']/text(),:)

declare function local:getCreators($score){
    for $creator in $score//creator
    return concat($creator/@type, '=', $creator/text())
};

declare function local:buildLyrics($lyric_list, $result){
    if (count($lyric_list)>0) then (
        let $lyric := $lyric_list[1]
        return
            if($lyric/syllabic/text() = 'single' or $lyric/syllabic/text() = 'end') then
                local:buildLyrics(subsequence($lyric_list, 2), concat($result, $lyric/text/text(), ' '))
            else 
                local:buildLyrics(subsequence($lyric_list, 2), concat($result, $lyric/text/text()))
    )
    else $result
};

let $lyrics := doc('music/SchbAvMaSample.xml')//lyric return
for $i in distinct-values($lyrics/@number)
return local:buildLyrics($lyrics[@number = $i], '')