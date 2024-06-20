﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	// регистр ОсновныеНачисления
	Движения.ОсновныеНачисления.Записывать = Истина;
	Для Каждого ТекСтрокаНачисления Из Начисления Цикл
		Движение = Движения.ОсновныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ПериодРегистрации = Дата;
		Движение.ВидРасчета = ТекСтрокаНачисления.ВидНачисления;
		Движение.ПериодДействияНачало = ТекСтрокаНачисления.ДатаНачала;
		Движение.ПериодДействияКонец = ТекСтрокаНачисления.ДатаОкончания;
		Движение.ПериодРегистрации = Дата;
		Движение.Сотрудник = ТекСтрокаНачисления.Сотрудник;
	КонецЦикла;
	
	// регистр ДополнительныеНачисления
	Движения.ДополнительныеНачисления.Записывать = Истина;
	Для Каждого ТекСтрокаНачисленияДоп Из НачисленияДоп Цикл
		Движение2 = Движения.ДополнительныеНачисления.Добавить();
		Движение2.Сторно = Ложь;
		Движение2.ВидРасчета = ТекСтрокаНачисленияДоп.ВидНачисления;
		Движение2.ПериодРегистрации = НачалоМесяца(Дата);
		Движение2.Сотрудник = ТекСтрокаНачисленияДоп.Сотрудник;
		Если Движение2.ВидРасчета = ПланыВидовРасчета.ДополнительныеНачисления.Премия Тогда
			Движение2.БазовыйПериодНачало = ДобавитьМесяц(НачалоМесяца(Движение2.ПериодРегистрации), -1);
			Движение2.БазовыйПериодКонец = КонецМесяца(Движение2.БазовыйПериодНачало);
			Движение2.ПроцентПремии = ТекСтрокаНачисленияДоп.Размер;
		Иначе
			Движение2.БазовыйПериодНачало = НачалоМесяца(Движение2.ПериодРегистрации);
			Движение2.БазовыйПериодКонец = КонецМесяца(Движение2.ПериодРегистрации);
		КонецЕсли;
		Если Движение2.ВидРасчета = ПланыВидовРасчета.ДополнительныеНачисления.Подарок Тогда
			Движение2.Результат = ТекСтрокаНачисленияДоп.Размер;
		Конецесли;
	КонецЦикла;
	
	// регистр Удержания
	Движения.Удержания.Записывать = Истина;
	Для Каждого ТекСтрокаНачисления Из Удержания Цикл
		Движение3 = Движения.Удержания.Добавить();
		Движение3.Сторно = Ложь;
		Движение3.ВидРасчета = ТекСтрокаНачисления.ВидУдержания;
		Движение3.Сотрудник = ТекСтрокаНачисления.Сотрудник;		
		Движение3.ПериодРегистрации = НачалоМесяца(Дата);
		Движение3.БазовыйПериодНачало = НачалоМесяца(Движение3.ПериодРегистрации);
		Движение3.БазовыйПериодКонец = КонецМесяца(Движение3.ПериодРегистрации);
	КонецЦикла;
	
	Движения.Записать();
	
	// Оклад (отработанные дни к плановым по графику * на оклад)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОсновныеНачисленияДанныеГрафика.Сотрудник КАК Сотрудник,
	|	ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
	|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеДниПериодДействия, 0) КАК ПланДни,
	|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеДниФактическийПериодДействия, 0) КАК ФактДни,
	|	ЕСТЬNULL(ОкладыСотрудниковСрезПоследних.Оклад, 0) КАК Оклад
	|ИЗ
	|	РегистрРасчета.ОсновныеНачисления.ДанныеГрафика(
	|			Регистратор = &Ссылка
	|				И ВидРасчета = &ВидРасчета) КАК ОсновныеНачисленияДанныеГрафика
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОкладыСотрудников.СрезПоследних(&Дата, ) КАК ОкладыСотрудниковСрезПоследних
	|		ПО ОсновныеНачисленияДанныеГрафика.Сотрудник = ОкладыСотрудниковСрезПоследних.Сотрудник";
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ОсновныеНачисления.Оклад);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Для Каждого СтрДвижения из Движения.ОсновныеНачисления Цикл
		Если СтрДвижения.ВидРасчета <> ПланыВидовРасчета.ОсновныеНачисления.Оклад Тогда
			Продолжить
		КонецЕсли;
		Выборка.Сбросить();
		Выборка.НайтиСледующий(СтрДвижения.НомерСтроки, "НомерСтроки");
		Если Выборка.Оклад = 0 Тогда
			Сообщить("Оклад для сотрудника " + Выборка.Сотрудник + " не установлен");
			Отказ = Истина;
			Возврат;
		КонецЕсли;
		СтрДвижения.Результат = ?(Выборка.ПланДни <>0, Выборка.ФактДни / Выборка.ПланДни * Выборка.Оклад, 0);
		СтрДвижения.Факт = Выборка.ФактДни;
		СтрДвижения.План = Выборка.ПланДни;
	КонецЦикла;
	Движения.ОсновныеНачисления.Записать(, Истина);
	
	//Премия % от начислений за прошлый месяц (оклад + подарок)
	
	МассивИзмерений = Новый Массив;
	МассивИзмерений.Добавить("Сотрудник");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЕСТЬNULL(ДополнительныеНачисленияБазаОсновныеНачисления.НомерСтроки, ДополнительныеНачисленияБазаДополнительныеНачисления.НомерСтроки) КАК НомерСтроки,
	|	ЕСТЬNULL(ДополнительныеНачисленияБазаОсновныеНачисления.РезультатБаза, 0) КАК РезультатБазаОсн,
	|	ЕСТЬNULL(ДополнительныеНачисленияБазаДополнительныеНачисления.РезультатБаза, 0) КАК РезультатБазаДоп
	|ИЗ
	|	РегистрРасчета.ДополнительныеНачисления.БазаДополнительныеНачисления(
	|			&МассивИзмерений,
	|			&МассивИзмерений,
	|			,
	|			ВидРасчета = &ВидРасчета
	|				И Регистратор = &Ссылка) КАК ДополнительныеНачисленияБазаДополнительныеНачисления
	|		ПОЛНОЕ СОЕДИНЕНИЕ РегистрРасчета.ДополнительныеНачисления.БазаОсновныеНачисления(
	|				&МассивИзмерений,
	|				&МассивИзмерений,
	|				,
	|				ВидРасчета = &ВидРасчета
	|					И Регистратор = &Ссылка) КАК ДополнительныеНачисленияБазаОсновныеНачисления
	|		ПО ДополнительныеНачисленияБазаДополнительныеНачисления.НомерСтроки = ДополнительныеНачисленияБазаОсновныеНачисления.НомерСтроки";
	
	Запрос.УстановитьПараметр("МассивИзмерений", МассивИзмерений);
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ДополнительныеНачисления.Премия);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Для Каждого СтрДвижения из Движения.ДополнительныеНачисления Цикл
		Если СтрДвижения.ВидРасчета <> ПланыВидовРасчета.ДополнительныеНачисления.Премия Тогда
			Продолжить
		КонецЕсли;
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(СтрДвижения.НомерСтроки, "НомерСтроки") Тогда
			СтрДвижения.Результат = (Выборка.РезультатБазаОсн + Выборка.РезультатБазаДоп) * СтрДвижения.ПроцентПремии / 100;
			СтрДвижения.БазаОсн = Выборка.РезультатБазаОсн;
			СтрДвижения.БазаДоп = Выборка.РезультатБазаДоп;
		Иначе
			Сообщить(Строка(СтрДвижения.Сотрудник) + " не получается начислить премию, т.к. отсутсвует база для начислений");
		КонецЕсли;
	КонецЦикла;
	Движения.ДополнительныеНачисления.Записать();
	
	// НДФЛ
	
	МассивИзмерений = Новый Массив;
	МассивИзмерений.Добавить("Сотрудник");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЕСТЬNULL(УдержанияБазаОсновныеНачисления.НомерСтроки, УдержанияБазаДополнительныеНачисления.НомерСтроки) КАК НомерСтроки,
	|	ЕСТЬNULL(УдержанияБазаОсновныеНачисления.РезультатБаза, 0) КАК РезультатБазаОсн,
	|	ЕСТЬNULL(УдержанияБазаДополнительныеНачисления.РезультатБаза, 0) КАК РезультатБазаДоп
	|ИЗ
	|	РегистрРасчета.Удержания.БазаОсновныеНачисления(
	|			&МассивИзмерений,
	|			&МассивИзмерений,
	|			,
	|			ВидРасчета = &ВидРасчета
	|				И Регистратор = &Регистратор) КАК УдержанияБазаОсновныеНачисления
	|		ПОЛНОЕ СОЕДИНЕНИЕ РегистрРасчета.Удержания.БазаДополнительныеНачисления(
	|				&МассивИзмерений,
	|				&МассивИзмерений,
	|				,
	|				ВидРасчета = &ВидРасчета
	|					И Регистратор = &Регистратор) КАК УдержанияБазаДополнительныеНачисления
	|		ПО УдержанияБазаОсновныеНачисления.НомерСтроки = УдержанияБазаДополнительныеНачисления.НомерСтроки";
	
	Запрос.УстановитьПараметр("МассивИзмерений", МассивИзмерений);
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.Удержания.НДФЛ);
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Для Каждого СтрДвижения из Движения.Удержания Цикл
		Если СтрДвижения.ВидРасчета <> ПланыВидовРасчета.Удержания.НДФЛ Тогда
			Продолжить
		КонецЕсли;
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(СтрДвижения.НомерСтроки, "НомерСтроки") Тогда
			СтрДвижения.Результат = (Выборка.РезультатБазаОсн + Выборка.РезультатБазаДоп) * 13 / 100;
			СтрДвижения.БазаОсн = Выборка.РезультатБазаОсн;
			СтрДвижения.БазаДоп = Выборка.РезультатБазаДоп;
		Иначе
			Сообщить(Строка(СтрДвижения.Сотрудник) + " не получается удержать НДФЛ, т.к. отсутсвует база для начислений");
		КонецЕсли;
	КонецЦикла;
	Движения.Удержания.Записать();
	
КонецПроцедуры
