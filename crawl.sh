#!/bin/sh

cd ~/work/memo/tools/crawl/
#＝＝＝クロールしたいサイトをここに指定＝＝＝
TAGET_SITE=
#＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

#ホームURL（サイト外に出て行ったりしたときに戻ってくるURLを指定）
SITE=
TAGET_LINK=${TAGET_SITE}

#urls_*.txtがあれば削除
ls crawl_res/urls_*.txt >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo '削除対象はありません。'
else
    rm -f crawl_res/urls_*.txt
fi

i=0
while [[ $i -lt 50 ]] #ここでクローリング回数を指定
do
    echo "クロール対象：${TAGET_LINK}"
    
    #ループに遅延処理を入れてサーバー負荷軽減
    sleep 1
    #hrefの中身をcrawl_res/links.txtに保存
    curl -s  ${TAGET_LINK} | grep -o 'href="[^"]*"' | sed -r 's/href="([^"]*)"/\1/g' > crawl_res/links.txt

    #たどれないリンクは削除
    sed -i '' '/^javascript/d' crawl_res/links.txt
    sed -i '' '/^Javascript/d' crawl_res/links.txt
    sed -i '' '/^JavaScript/d' crawl_res/links.txt
    sed -i '' '/^#/d' crawl_res/links.txt
    sed -i '' '/^\/$/d' crawl_res/links.txt
    sed -i '' '/css$/d' crawl_res/links.txt
        
    #リンクがなかった場合はホームURLからやりなおし
    COUNT=`cat crawl_res/links.txt | wc -l `
    if [ ${COUNT} = 0 ]; then
        TAGET_LINK=${SITE}
        continue
    fi

    echo "======${TAGET_LINK}======" > crawl_res/urls_${i}.txt
    while read line
    do
    #「/（スラッシュ）」で始まっていたら、先頭に${SITE}を追加
    FIRST=`echo ${line} | cut -c 1-1`
        if [ "${FIRST}" = "/" ]; then
            echo ${SITE}${line} >> crawl_res/urls_${i}.txt
        else
            echo ${line} >> crawl_res/urls_${i}.txt
        fi
    done < crawl_res/links.txt

    #crawl_res/urls_${i}.txtからランダムで1行を取得する
    SHUF_URL=`shuf -n 1 crawl_res/urls_${i}.txt`
    
    #${SHUF_URL}で取得したリンクが外部サイトだったらやりなおし
    if [[ "${SHUF_URL}" =~ "${SITE}" ]]; then
        #取得したランダムURLのステータスが200じゃなければやりなおし
        RESPONCE="$(curl -s -o /dev/null -w "%{http_code}" ${SHUF_URL})"
        if [ ${RESPONCE} = 200 ]; then
            # 前回と同じリンクを辿ろうとしたらトップからやり直し
            if [ ${TAGET_LINK} != ${SHUF_URL} ]; then
                TAGET_LINK=${SHUF_URL}
                i=`expr $i + 1` #ループを１つ進める
            else
                TAGET_LINK=${SITE}
                i=`expr $i + 1` #ループを１つ進める
            fi
        else
            continue
        fi
    else
        continue
    fi
done