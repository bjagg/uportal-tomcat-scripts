#!/bin/bash

# Expecting the first (and only) argument to be the path to Tomcat
if [ ! -d $1 ]; then
    echo "Argument should be the path to Tomcat"
    exit 1
fi

echo
echo -e "\t** Update conf/catalina.properties with shared.loader=shared/lib"
echo

# Test for catalina.properties
CAT_PROP_FILE=$1/conf/catalina.properties
if [ ! -f ${CAT_PROP_FILE} ]; then
    echo "Could not find ${CAT_PROP_FILE}"
    exit 1
fi

# Is the line already updated?
SHARED_LOADER_NEW_LINE='shared.loader=${catalina.base}/shared/lib/*.jar'
CAT_PROP_UPDATED=`grep -Fx ${SHARED_LOADER_NEW_LINE} ${CAT_PROP_FILE} | wc -l`
if [ 1 -eq ${CAT_PROP_UPDATED} ]; then
    echo "${CAT_PROP_FILE} is already updated with ${SHARED_LOADER_NEW_LINE}"
else    
    # Need to update, so make a backup if one doesn't exist
    CAT_PROP_BACKUP=${CAT_PROP_FILE}.bak
    if [ ! -f ${CAT_PROP_BACKUP} ]; then
        echo "Copying ${CAT_PROP_FILE} to ${CAT_PROP_BACKUP}"
        cp ${CAT_PROP_FILE} ${CAT_PROP_BACKUP}
    else
        # Make sure backup matches file
        diff ${CAT_PROP_FILE} ${CAT_PROP_BACKUP} > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "${CAT_PROP_FILE} differs from ${CAT_PROP_BACKUP} ..."
            diff ${CAT_PROP_FILE} ${CAT_PROP_BACKUP}
            exit 1
        fi
    fi
    # Make the substitution
    SHARED_LOADER_OLD_LINE='shared.loader='
    SHARED_LOADER_BLANK=`grep -Fx ${SHARED_LOADER_OLD_LINE} ${CAT_PROP_FILE} | wc -l`
    if [ 1 -eq ${SHARED_LOADER_BLANK} ]; then
        echo "Updating shared.loader= line ..."
        sed -e "s:^${SHARED_LOADER_OLD_LINE}\$:${SHARED_LOADER_NEW_LINE}:" ${CAT_PROP_BACKUP} > ${CAT_PROP_FILE}
    else
        echo "The value for shared.loader is not expected blank value for ${CAT_PROP_FILE}."
    fi
fi


echo
echo -e "\t** Allow shared sessions in conf/context.xml"
echo

# Test for conf/context.xml
CTXT_FILE=$1/conf/context.xml
if [ ! -f ${CTXT_FILE} ]; then
    echo "Could not find ${CTXT_FILE}"
    exit 1
fi

# is the line already updated?
CONTEXT_NEW_LINE='<Context sessionCookiePath="/">'
CONTEXT_UPDATED=`grep -Fx "${CONTEXT_NEW_LINE}" ${CTXT_FILE} | wc -l`
if [ 1 -eq ${CONTEXT_UPDATED} ]; then
    echo "${CTXT_FILE} is alrady updated with ${CONTEXT_NEW_LINE}"
else
    # Need to update, so make a backup if one doesn't exist
    CTXT_BACKUP=${CTXT_FILE}.bak
    if [ ! -f ${CTXT_BACKUP} ]; then
        echo "Copying ${CTXT_FILE} to ${CTXT_BACKUP}"
        cp ${CTXT_FILE} ${CTXT_BACKUP}
    else
        # existing backup file, so make sure it matches
        diff ${CTXT_FILE} ${CTXT_BACKUP}> /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "${CTXT_FILE} differs from ${CTXT_BACKUP} ..."
            diff ${CTXT_FILE} ${CTXT_BACKUP}
            exit 1
        fi
    fi
    # Make the substitution
    CONTEXT_OLD_LINE='<Context>'
    CONTEXT_IS_OLD=`grep -Fx "${CONTEXT_OLD_LINE}" ${CTXT_FILE} | wc -l`
    if [ 1 -eq ${CONTEXT_IS_OLD} ]; then
        echo "Updating ${CONTEXT_OLD_LINE} to ${CONTEXT_NEW_LINE} ..."
        sed -e "s:^${CONTEXT_OLD_LINE}\$:${CONTEXT_NEW_LINE}:" ${CTXT_BACKUP} > ${CTXT_FILE}
    else
        echo "The value for <Context> is not the expected value for ${CTXT_FILE}."
    fi
fi

echo
echo -e "\t** Check setenv.sh"
echo

SETENV_FILE=$1/bin/setenv.sh
if [ -f ${SETENV_FILE} ]; then
    echo "Found ${SETENV_FILE} ..."
else
    echo "Copying setenv.sh to ${SETENV_FILE} ..."
    cp setenv.sh $SETENV_FILE
fi
cat ${SETENV_FILE}

echo 
echo "Done."
echo
