#!/bin/sh

#=================================================================
#crowl.shで洗い出したURLからgrepする
#=================================================================

cd ~/work/memo/tools/crawl/

#===========grepしたいワードを設定===============
TAGET_WORD=""
TAGET_WORD_2=""
#=============================================

#grep_res/grep_list.txtがあれば削除
ls grep_res/grep_list.txt >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo '削除対象はありません。'
else
    rm -f grep_res/grep_list.txt
fi

grep -r ${TAGET_WORD} ./crawl_res >> grep_res/grep_list.txt
grep -r ${TAGET_WORD_2} ./crawl_res >> grep_res/grep_list.txt