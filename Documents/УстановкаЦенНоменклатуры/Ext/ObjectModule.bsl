﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ДанныеЗаполнения <> Неопределено Тогда
		Курс = ПолучениеДанныхНаСервере.ПолучитьКурс(ДанныеЗаполнения.Валюта, Дата);
		Если НЕ Курс Тогда
			Сообщить("Для валюты " + ДанныеЗаполнения.Валюта + " курс не установлен или равен 0");
			Отказ = Истина;
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ПоступлениеТоваров") Тогда
		// Заполнение шапки из ПоступлениеТоваров
		
		ВидЦены = ДанныеЗаполнения.ВидЦены;
		Основание = ДанныеЗаполнения;
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0) КАК Цена,
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследнихСЦеной.Цена, 0) КАК СтараяЦена,
		|	ПоступлениеТоваровТовары.Номенклатура КАК Номенклатура,
		|	СУММА(ПоступлениеТоваровТовары.Количество) КАК Количество,
		|	СУММА(ПоступлениеТоваровТовары.Стоимость) КАК Стоимость
		|ПОМЕСТИТЬ ВТ_НоменклатураСНулевойЦенойНаДату
		|ИЗ
		|	Документ.ПоступлениеТоваров.Товары КАК ПоступлениеТоваровТовары
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
		|				,
		|				Период = &Дата
		|					И ВидЦены = &ВидЦены) КАК ЦеныНоменклатурыСрезПоследних
		|		ПО ПоступлениеТоваровТовары.Номенклатура = ЦеныНоменклатурыСрезПоследних.Номенклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(, ВидЦены = &ВидЦены) КАК ЦеныНоменклатурыСрезПоследнихСЦеной
		|		ПО ПоступлениеТоваровТовары.Номенклатура = ЦеныНоменклатурыСрезПоследнихСЦеной.Номенклатура
		|ГДЕ
		|	ПоступлениеТоваровТовары.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ПоступлениеТоваровТовары.Номенклатура,
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0),
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследнихСЦеной.Цена, 0)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Номенклатура.Номенклатура КАК Номенклатура,
		|	ВТ_Номенклатура.СтараяЦена КАК СтараяЦена,
		|	ВТ_Номенклатура.Количество КАК Количество,
		|	ВТ_Номенклатура.Стоимость КАК Стоимость
		|ИЗ
		|	ВТ_НоменклатураСНулевойЦенойНаДату КАК ВТ_Номенклатура
		|ГДЕ
		|	ВТ_Номенклатура.Цена = 0";
		
		Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
		Запрос.УстановитьПараметр("ВидЦены", ДанныеЗаполнения.ВидЦены);
		Запрос.УстановитьПараметр("Дата", НачалоДня(ЭтотОбъект.Дата));
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			НоваяСтрока = Товары.Добавить();
			НоваяСтрока.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
			НоваяСтрока.СтараяЦена = ВыборкаДетальныеЗаписи.СтараяЦена;
			НоваяСтрока.Цена = ?(ВыборкаДетальныеЗаписи.Количество <> 0, ВыборкаДетальныеЗаписи.Стоимость * Курс / ВыборкаДетальныеЗаписи.Количество, 0);
		КонецЦикла;
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.РеализацияТоваров") Тогда
		// Заполнение шапки 
		ВидЦены = ДанныеЗаполнения.ВидЦены;
		Основание = ДанныеЗаполнения;

		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0) КАК Цена,
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследнихСЦеной.Цена, 0) КАК СтараяЦена,
		|	РеализацияТоваровТовары.Номенклатура КАК Номенклатура,
		|	СУММА(РеализацияТоваровТовары.Количество) КАК Количество,
		|	СУММА(РеализацияТоваровТовары.Стоимость) КАК Стоимость
		|ПОМЕСТИТЬ ВТ_НоменклатураСНулевойЦенойНаДату
		|ИЗ
		|	Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
		|				,
		|				Период = &Дата
		|					И ВидЦены = &ВидЦены) КАК ЦеныНоменклатурыСрезПоследних
		|		ПО РеализацияТоваровТовары.Номенклатура = ЦеныНоменклатурыСрезПоследних.Номенклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(, ВидЦены = &ВидЦены) КАК ЦеныНоменклатурыСрезПоследнихСЦеной
		|		ПО РеализацияТоваровТовары.Номенклатура = ЦеныНоменклатурыСрезПоследнихСЦеной.Номенклатура
		|ГДЕ
		|	РеализацияТоваровТовары.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	РеализацияТоваровТовары.Номенклатура,
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0),
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследнихСЦеной.Цена, 0)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Номенклатура.Номенклатура КАК Номенклатура,
		|	ВТ_Номенклатура.СтараяЦена КАК СтараяЦена,
		|	ВТ_Номенклатура.Количество КАК Количество,
		|	ВТ_Номенклатура.Стоимость КАК Стоимость
		|ИЗ
		|	ВТ_НоменклатураСНулевойЦенойНаДату КАК ВТ_Номенклатура
		|ГДЕ
		|	ВТ_Номенклатура.Цена = 0";
		
		Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
		Запрос.УстановитьПараметр("ВидЦены", ДанныеЗаполнения.ВидЦены);
		Запрос.УстановитьПараметр("Дата", НачалоДня(ЭтотОбъект.Дата));
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			НоваяСтрока = Товары.Добавить();
			НоваяСтрока.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
			НоваяСтрока.СтараяЦена = ВыборкаДетальныеЗаписи.СтараяЦена;
			НоваяСтрока.Цена = ?(ВыборкаДетальныеЗаписи.Количество <> 0, ВыборкаДетальныеЗаписи.Стоимость * Курс / ВыборкаДетальныеЗаписи.Количество, 0);
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	// регистр ЦеныНоменклатуры
	Движения.ЦеныНоменклатуры.Записывать = Истина;
	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ЦеныНоменклатуры.Добавить();
		Движение.Период = НачалоДня(Дата);
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.ВидЦены = ВидЦены;
		Движение.Цена = ТекСтрокаТовары.Цена;
	КонецЦикла;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	ЭтотОбъект.Дата = НачалоДня(ЭтотОбъект.Дата);  
	
КонецПроцедуры

