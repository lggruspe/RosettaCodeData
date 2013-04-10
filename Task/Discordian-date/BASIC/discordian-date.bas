#INCLUDE "datetime.bi"

DECLARE FUNCTION julian(AS DOUBLE) AS INTEGER


SeasonNames:
DATA "Chaos", "Discord", "Confusion", "Bureaucracy", "The Aftermath"
Weekdays:
DATA "Setting Orange", "Sweetmorn", "Boomtime", "Pungenday", "Prickle-Prickle"
DaysPreceding1stOfMonth:
'   jan feb mar apr may  jun  jul  aug  sep  oct  nov  dec
DATA 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334

DIM dyear AS INTEGER, dseason AS STRING, dday AS INTEGER, dweekday AS STRING
DIM tmpdate AS DOUBLE, jday AS INTEGER, result AS STRING
DIM L0 AS INTEGER

IF LEN(COMMAND$) THEN
    tmpdate = DATEVALUE(COMMAND$)
ELSE
    tmpdate = FIX(NOW())
END IF
dyear = YEAR(tmpdate) + 1166
IF (2 = MONTH(tmpdate)) AND (29 = DAY(tmpdate)) THEN
    result = "Saint Tib's Day, " & STR$(dyear) & " YOLD"
ELSE
    jday = julian(tmpdate)
    RESTORE SeasonNames
    FOR L0 = 1 TO (jday \ 73) + 1
    	READ dseason
    NEXT
    dday = (jday MOD 73)
    IF 0 = dday THEN dday = 73
    RESTORE Weekdays
    FOR L0 = 1 TO (jday MOD 5) + 1
        READ dweekday
    NEXT
    result = dweekday & ", " & dseason & " " & TRIM$(STR$(dday)) & ", " & TRIM$(STR$(dyear)) & " YOLD"
END IF

? result
END

FUNCTION julian(d AS DOUBLE) AS INTEGER
    'doesn't account for leap years (not needed for ddate)
    DIM tmp AS INTEGER, L1 AS INTEGER
    RESTORE DaysPreceding1stOfMonth
    FOR L1 = 1 TO MONTH(d)
        READ tmp
    NEXT
    FUNCTION = tmp + DAY(d)
END FUNCTION
