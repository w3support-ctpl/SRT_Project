-- Function Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP FUNCTION IF EXISTS `NumberInWords` ;;
CREATE DEFINER=`appuser`@`%` FUNCTION `NumberInWords`(n INT) RETURNS varchar(1000) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
declare ans varchar(1000);
    declare dig1, dig2, dig3,dig4,dig5,dig6,dig7,dig8,dig9 int;

    set ans = '';
    set dig9 = floor(n/100000000);
    set dig8 = floor(n/10000000) - dig9*10;
    set dig7 = floor(n/1000000) -(floor(n/10000000)*10);
    set dig6 = floor(n/100000) - (floor(n/1000000)*10);
    set dig5 = floor(n/10000) -  (floor(n/100000)*10);
    set dig4 = floor(n/1000) -   (floor(n/10000)*10);
    set dig3 = floor(n/100) -    (floor(n/1000)*10);
    set dig2 = floor(n/10) -     (floor(n/100)*10);
    set dig1 = n - (floor(n / 10)*10);
	if dig7 = 1 then
        case
            when (dig7*10 + dig6) = 10 then set ans=concat(ans,'Ten Lakhs');
            when (dig7*10 + dig6) = 11 then set ans=concat(ans,'Eleven Lakhs');
            when (dig7*10 + dig6) = 12 then set ans=concat(ans,'Twelve Lakhs');
            when (dig7*10 + dig6) = 13 then set ans=concat(ans,'Thirteen Lakhs');
            when (dig7*10 + dig6) = 14 then set ans=concat(ans,'Fourteen Lakhs');
            when (dig7*10 + dig6) = 15 then set ans=concat(ans,'Fifteen Lakhs');
            when (dig7*10 + dig6) = 16 then set ans=concat(ans,'Sixteen Lakhs');
            when (dig7*10 + dig6) = 17 then set ans=concat(ans,'Seventeen Lakhs');
            when (dig7*10 + dig6) = 18 then set ans=concat(ans,'Eighteen Lakhs');
            when (dig7*10 + dig6) = 19 then set ans=concat(ans,'Nineteen Lakhs');
            else set ans=ans;
        end case;
    else
        if dig7 > 0 then
            case
                when dig7=2 then set ans=concat(ans, ' Twenty');
                when dig7=3 then set ans=concat(ans, ' Thirty');
                when dig7=4 then set ans=concat(ans, ' Fourty');
                when dig7=5 then set ans=concat(ans, ' Fifty');
                when dig7=6 then set ans=concat(ans, ' Sixty');
                when dig7=7 then set ans=concat(ans, ' Seventy');
                when dig7=8 then set ans=concat(ans, ' Eighty');
                when dig7=9 then set ans=concat(ans, ' Ninety');
                else set ans=ans;
            end case;
            if ans <> '' and dig6 =0 then
				set ans=concat(ans, ' Thousand');
            end if;
        end if;
        if ans <> '' and dig6 > 0 and dig7 =0 then
			set ans=concat(ans, ' ');
        end if;
        if dig6 > 0 then
			case
				when dig6=1 then set ans=concat(ans, ' One Lakhs');
				when dig6=2 then set ans=concat(ans, ' Two Lakhs');
				when dig6=3 then set ans=concat(ans, ' Three Lakhs');
				when dig6=4 then set ans=concat(ans, ' Four Lakhs');
				when dig6=5 then set ans=concat(ans, ' Five Lakhs');
				when dig6=6 then set ans=concat(ans, ' Six Lakhs');
				when dig6=7 then set ans=concat(ans, ' Seven Lakhs');
				when dig6=8 then set ans=concat(ans, ' Eight Lakhs');
				when dig6=9 then set ans=concat(ans, ' Nine Lakhs');
				else set ans = ans;
			end case;
		end if;
	end if;
    if ans <> '' and dig5 > 0 then
        set ans=concat(ans, '');
    end if;
    if dig5 = 1 then
        case
            when (dig5*10 + dig4) = 10 then set ans=concat(ans,'Ten Thousand');
            when (dig5*10 + dig4) = 11 then set ans=concat(ans,'Eleven Thousand');
            when (dig5*10 + dig4) = 12 then set ans=concat(ans,'Twelve Thousand');
            when (dig5*10 + dig4) = 13 then set ans=concat(ans,'Thirteen Thousand');
            when (dig5*10 + dig4) = 14 then set ans=concat(ans,'Fourteen Thousand');
            when (dig5*10 + dig4) = 15 then set ans=concat(ans,'Fifteen Thousand');
            when (dig5*10 + dig4) = 16 then set ans=concat(ans,'Sixteen Thousand');
            when (dig5*10 + dig4) = 17 then set ans=concat(ans,'Seventeen Thousand');
            when (dig5*10 + dig4) = 18 then set ans=concat(ans,'Eighteen Thousand');
            when (dig5*10 + dig4) = 19 then set ans=concat(ans,'Nineteen Thousand');
            else set ans=ans;
        end case;
    else
        if dig5 > 0 then
            case
                when dig5=2 then set ans=concat(ans, ' Twenty');
                when dig5=3 then set ans=concat(ans, ' Thirty');
                when dig5=4 then set ans=concat(ans, ' Fourty');
                when dig5=5 then set ans=concat(ans, ' Fifty');
                when dig5=6 then set ans=concat(ans, ' Sixty');
                when dig5=7 then set ans=concat(ans, ' Seventy');
                when dig5=8 then set ans=concat(ans, ' Eighty');
                when dig5=9 then set ans=concat(ans, ' Ninety');
                else set ans=ans;
            end case;
            if ans <> '' and dig4 =0 then
				set ans=concat(ans, ' Thousand');
            end if;
        end if;
        if ans <> '' and dig4 > 0 and dig5 =0 then
			set ans=concat(ans, ' ');
        end if;
        if dig4 > 0 then
			case
				when dig4=1 then set ans=concat(ans, ' One Thousand');
				when dig4=2 then set ans=concat(ans, ' Two Thousand');
				when dig4=3 then set ans=concat(ans, ' Three Thousand');
				when dig4=4 then set ans=concat(ans, ' Four Thousand');
				when dig4=5 then set ans=concat(ans, ' Five Thousand');
				when dig4=6 then set ans=concat(ans, ' Six Thousand');
				when dig4=7 then set ans=concat(ans, ' Seven Thousand');
				when dig4=8 then set ans=concat(ans, ' Eight Thousand');
				when dig4=9 then set ans=concat(ans, ' Nine Thousand');
				else set ans = ans;
			end case;
		end if;
	end if;
    if ans <> '' and dig3 > 0 then
        set ans=concat(ans, ' ');
    end if;
    if dig3 > 0 then
        case
            when dig3=1 then set ans=concat(ans, 'One Hundred');
            when dig3=2 then set ans=concat(ans, 'Two Hundred');
            when dig3=3 then set ans=concat(ans, 'Three Hundred');
            when dig3=4 then set ans=concat(ans, 'Four Hundred');
            when dig3=5 then set ans=concat(ans, 'Five Hundred');
            when dig3=6 then set ans=concat(ans, 'Six Hundred');
            when dig3=7 then set ans=concat(ans, 'Seven Hundred');
            when dig3=8 then set ans=concat(ans, 'Eight Hundred');
            when dig3=9 then set ans=concat(ans, 'Nine Hundred');
            else set ans = ans;
        end case;
    end if;
    if ans <> '' and dig2 > 0 then
        set ans=concat(ans, ' ');
    end if;
    if dig2 = 1 then
        case
            when (dig2*10 + dig1) = 10 then set ans=concat(ans,'Ten');
            when (dig2*10 + dig1) = 11 then set ans=concat(ans,'Eleven');
            when (dig2*10 + dig1) = 12 then set ans=concat(ans,'Twelve');
            when (dig2*10 + dig1) = 13 then set ans=concat(ans,'Thirteen');
            when (dig2*10 + dig1) = 14 then set ans=concat(ans,'Fourteen');
            when (dig2*10 + dig1) = 15 then set ans=concat(ans,'Fifteen');
            when (dig2*10 + dig1) = 16 then set ans=concat(ans,'Sixteen');
            when (dig2*10 + dig1) = 17 then set ans=concat(ans,'Seventeen');
            when (dig2*10 + dig1) = 18 then set ans=concat(ans,'Eighteen');
            when (dig2*10 + dig1) = 19 then set ans=concat(ans,'Nineteen');
            else set ans=ans;
        end case;
    else
        if dig2 > 0 then
            case
                when dig2=2 then set ans=concat(ans, ' Twenty');
                when dig2=3 then set ans=concat(ans, ' Thirty');
                when dig2=4 then set ans=concat(ans, ' Fourty');
                when dig2=5 then set ans=concat(ans, ' Fifty');
                when dig2=6 then set ans=concat(ans, ' Sixty');
                when dig2=7 then set ans=concat(ans, ' Seventy');
                when dig2=8 then set ans=concat(ans, ' Eighty');
                when dig2=9 then set ans=concat(ans, ' Ninety');
                else set ans=ans;
            end case;
        end if;
        if ans <> '' and dig1 > 0 and dig2 =0 then
			set ans=concat(ans, ' ');
        end if;
        if dig1 > 0 then
            case
                when dig1=1 then set ans=concat(ans, ' One');
                when dig1=2 then set ans=concat(ans, ' Two');
                when dig1=3 then set ans=concat(ans, ' Three');
                when dig1=4 then set ans=concat(ans, ' Four');
                when dig1=5 then set ans=concat(ans, ' Five');
                when dig1=6 then set ans=concat(ans, ' Six');
                when dig1=7 then set ans=concat(ans, ' Seven');
                when dig1=8 then set ans=concat(ans, ' Eight');
                when dig1=9 then set ans=concat(ans, ' Nine');
                else set ans=ans;
            end case;
        end if;
    end if;

    return trim(ans);
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:33
