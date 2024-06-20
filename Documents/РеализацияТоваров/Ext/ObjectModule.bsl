﻿
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	СуммаПоДокументу = Товары.Итог("Стоимость");
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказКлиента") Тогда
		ТипОснованиеСтрока = СтрЗаменить(ДанныеЗаполнения.Метаданные().ПолноеИмя(), "Документ.", "");
		ТипДокументаСтрока = СтрЗаменить(ЭтотОбъект.Ссылка.Метаданные().ПолноеИмя(), "Документ.", "");
		Документ = ПолучениеДанныхНаСервере.ЕстьДокументВведенныйНаОсновании(ДанныеЗаполнения.Ссылка, ТипОснованиеСтрока, ТипДокументаСтрока);
		Если Документ = Ложь Тогда
			// Заполнение шапки
			Основание = ДанныеЗаполнения.Ссылка;
			Валюта = ДанныеЗаполнения.Валюта;
			ВидЦены = ДанныеЗаполнения.ВидЦены;
			Договор = ДанныеЗаполнения.Договор;
			Покупатель = ДанныеЗаполнения.Покупатель;
			Склад = ДанныеЗаполнения.Склад;
			СуммаПоДокументу = ДанныеЗаполнения.СуммаПоДокументу;
			Для Каждого ТекСтрокаТовары Из ДанныеЗаполнения.Товары Цикл
				НоваяСтрока = Товары.Добавить();
				НоваяСтрока.Количество = ТекСтрокаТовары.Количество;
				НоваяСтрока.Номенклатура = ТекСтрокаТовары.Номенклатура;
				НоваяСтрока.Стоимость = ТекСтрокаТовары.Стоимость;
				НоваяСтрока.Цена = ТекСтрокаТовары.Цена;
			КонецЦикла;	
		Иначе
			ВызватьИсключение("По " + СлужебныеПроцедурыНаСервере.СформироватьПредставлениеДокумента(ДанныеЗаполнения.Ссылка) + 
			" уже существует " + СлужебныеПроцедурыНаСервере.СформироватьПредставлениеДокумента(Документ));
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Метод = ПолучениеДанныхНаСервере.ПолучитьМетодСписанияСебестоимости(Дата);
	Если Метод = Неопределено Тогда
		Сообщить("Не установлен метод списания себестоимости");
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	Если Валюта <> Справочники.Валюты.Рубль Тогда
		Курс = ПолучениеДанныхНаСервере.ПолучитьКурс(Валюта, Дата);
		Если НЕ Курс Тогда
			Сообщить("Для валюты " + Валюта + " курс не установлен или равен 0");
			Отказ = Истина;
			Возврат;
		КонецЕсли;
	ИначеЕсли Валюта = Справочники.Валюты.Рубль Тогда
		Курс = 1;
	КонецЕсли;
	
	Движения.ТоварыНаСкладах.Записывать = Истина;
	Движения.Прибыль.Записывать = Истина;
	Движения.Продажи.Записывать = Истина;
	Движения.Хозрасчетный.Записывать = Истина;
	Движения.ТоварыНаСкладах.Записать();
	Движения.Хозрасчетный.Записать();
	
	// ОУ 
	
	// регистр ТоварыНаСкладах Расход
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РеализацияТоваровТовары.Номенклатура КАК Номенклатура,
	|	СУММА(РеализацияТоваровТовары.Количество) КАК Количество,
	|	СУММА(РеализацияТоваровТовары.Стоимость) КАК Стоимость
	|ПОМЕСТИТЬ ТЧ_Товары
	|ИЗ
	|	Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
	|ГДЕ
	|	РеализацияТоваровТовары.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	РеализацияТоваровТовары.Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЧ_Товары.Номенклатура КАК Номенклатура,
	|	ТЧ_Товары.Количество КАК Количество,
	|	ТЧ_Товары.Стоимость КАК Стоимость,
	|	ТоварыНаСкладахОстатки.Партия КАК Партия,
	|	ТоварыНаСкладахОстатки.Склад КАК Склад,
	|	ЕСТЬNULL(ТоварыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
	|	ЕСТЬNULL(ТоварыНаСкладахОстатки.СуммаОстаток, 0) КАК СуммаОстаток
	|ИЗ
	|	ТЧ_Товары КАК ТЧ_Товары
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(
	|				&МоментВремени,
	|				Номенклатура В
	|						(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|							ТЧ_Товары.Номенклатура КАК Номенклатура
	|						ИЗ
	|							ТЧ_Товары КАК ТЧ_Товары)
	|					И Склад = &Склад) КАК ТоварыНаСкладахОстатки
	|		ПО ТЧ_Товары.Номенклатура = ТоварыНаСкладахОстатки.Номенклатура
	|
	|УПОРЯДОЧИТЬ ПО
	|	ТоварыНаСкладахОстатки.Партия.МоментВремени
	|ИТОГИ
	|	МАКСИМУМ(Количество),
	|	МАКСИМУМ(Стоимость),
	|	СУММА(КоличествоОстаток),
	|	СУММА(СуммаОстаток)
	|ПО
	|	Номенклатура";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Склад", Склад);
	
	Если Метод = Перечисления.МетодыСписанияСебестоимости.LIFO Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"УПОРЯДОЧИТЬ ПО ТоварыНаСкладахОстатки.Партия.МоментВремени","УПОРЯДОЧИТЬ ПО ТоварыНаСкладахОстатки.Партия.МоментВремени УБЫВ");
	КонецЕсли;
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		Если ВыборкаНоменклатура.Количество > ВыборкаНоменклатура.КоличествоОстаток Тогда
			Сообщить("ОУ: Товара " + ВыборкаНоменклатура.Номенклатура +  
			" недостаточно на складе " + Склад + " текущий остаток " + 
			ВыборкаНоменклатура.КоличествоОстаток + " шт.");
			Отказ = Истина;
			Возврат;
		КонецЕсли;
		
		СебестоимостьПоСтроке = 0;
		ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
		ОсталосьСписать = ВыборкаНоменклатура.Количество;
		Пока ВыборкаДетальныеЗаписи.Следующий() И ОсталосьСписать > 0 Цикл
			ЦенаЗаЕдиницу = ВыборкаДетальныеЗаписи.СуммаОстаток / ВыборкаДетальныеЗаписи.КоличествоОстаток;
			Движение = Движения.ТоварыНаСкладах.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.Склад = Склад;
			Движение.Партия = ВыборкаДетальныеЗаписи.Партия;
			Движение.Количество = мин(ОсталосьСписать, ВыборкаДетальныеЗаписи.КоличествоОстаток);
			Если ВыборкаДетальныеЗаписи.КоличествоОстаток = Движение.Количество Тогда
				Движение.Сумма = ВыборкаДетальныеЗаписи.СуммаОстаток;
			Иначе
				Движение.Сумма = ЦенаЗаЕдиницу * Движение.Количество;
			КонецЕсли;
			ОсталосьСписать = ОсталосьСписать - Движение.Количество;
			СебестоимостьПоСтроке = СебестоимостьПоСтроке + Движение.Сумма;
		КонецЦикла; 
		// регистр Прибыль Товары
		Движение = Движения.Прибыль.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = ВыборкаНоменклатура.Номенклатура;
		Движение.Сумма = ВыборкаНоменклатура.Стоимость * Курс - СебестоимостьПоСтроке;
		// регистр Продажи
		Движение = Движения.Продажи.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = ВыборкаНоменклатура.Номенклатура;
		Движение.Контрагент = Покупатель;
		Движение.Склад = Склад;
		Движение.Сумма = ВыборкаНоменклатура.Стоимость * Курс;
		Движение.Количество = ВыборкаНоменклатура.Количество;
		
	КонецЦикла;
	
	//БУ
	// регистр Хозрасчетный
	
	ВидыСубконто = Новый Массив;
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Склады);
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Партии);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РеализацияТоваровТовары.Номенклатура КАК Номенклатура,
	|	СУММА(РеализацияТоваровТовары.Количество) КАК Количество,
	|	СУММА(РеализацияТоваровТовары.Стоимость) КАК Стоимость
	|ПОМЕСТИТЬ ВТ_ДокументТЧ
	|ИЗ
	|	Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
	|ГДЕ
	|	РеализацияТоваровТовары.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	РеализацияТоваровТовары.Номенклатура
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДокументТЧ.Номенклатура КАК Номенклатура,
	|	ВТ_ДокументТЧ.Количество КАК Количество,
	|	ЕСТЬNULL(ХозрасчетныйОстаткиПоСкладамИПартиям.КоличествоОстатокДт, 0) КАК КоличествоОстатокПоПартиям,
	|	ХозрасчетныйОстаткиПоСкладамИПартиям.Субконто3 КАК Партия,
	|	ВТ_ДокументТЧ.Стоимость КАК Стоимость,
	|	ЕСТЬNULL(ХозрасчетныйОстаткиПоВСЕМ.СуммаОстатокДт, 0) КАК СуммаОстатокПоВсем,
	|	ЕСТЬNULL(ХозрасчетныйОстаткиПоВСЕМ.КоличествоОстатокДт, 0) КАК КоличествоОстатокПоВсем,
	|	ВТ_ДокументТЧ.Номенклатура.Представление КАК НоменклатураПредставление
	|ИЗ
	|	ВТ_ДокументТЧ КАК ВТ_ДокументТЧ
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Хозрасчетный.Остатки(
	|				&МоментВремени,
	|				Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ТоварыНаСкладах),
	|				&ВидыСубконто,
	|				Субконто1 В
	|						(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|							ВТ_ДокументТЧ.Номенклатура КАК Номенклатура
	|						ИЗ
	|							ВТ_ДокументТЧ КАК ВТ_ДокументТЧ)
	|					И Субконто2 = &Склад) КАК ХозрасчетныйОстаткиПоСкладамИПартиям
	|		ПО ВТ_ДокументТЧ.Номенклатура = ХозрасчетныйОстаткиПоСкладамИПартиям.Субконто1
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Хозрасчетный.Остатки(
	|				&МоментВремени,
	|				Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ТоварыНаСкладах),
	|				&ВидыСубконто,
	|				Субконто1 В
	|					(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|						ВТ_ДокументТЧ.Номенклатура КАК Номенклатура
	|					ИЗ
	|						ВТ_ДокументТЧ КАК ВТ_ДокументТЧ)) КАК ХозрасчетныйОстаткиПоВСЕМ
	|		ПО ВТ_ДокументТЧ.Номенклатура = ХозрасчетныйОстаткиПоВСЕМ.Субконто1
	|ИТОГИ
	|	МАКСИМУМ(Количество),
	|	СУММА(КоличествоОстатокПоПартиям),
	|	МАКСИМУМ(Стоимость),
	|	МАКСИМУМ(СуммаОстатокПоВсем),
	|	МАКСИМУМ(КоличествоОстатокПоВсем)
	|ПО
	|	Номенклатура";
	
	Запрос.УстановитьПараметр("ВидыСубконто", ВидыСубконто);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		Если ВыборкаНоменклатура.Количество > ВыборкаНоменклатура.КоличествоОстатокПоПартиям Тогда
			Сообщить("БУ Товара: " + ВыборкаНоменклатура.НоменклатураПредставление 
			+ " недостаточно на складе " + Склад, " текущий остаток " 
			+ ВыборкаНоменклатура.КоличествоОстатокПоПартиям + " шт.");
			Отказ = Истина;
		КонецЕсли;
		Себестоимость = ВыборкаНоменклатура.СуммаОстатокПоВсем / ВыборкаНоменклатура.КоличествоОстатокПоВсем;
		Если Не Отказ Тогда
			ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
			ОсталосьСписать = ВыборкаНоменклатура.Количество;
			Пока  ВыборкаДетальныеЗаписи.Следующий() И ОсталосьСписать > 0 Цикл
				Движение = Движения.Хозрасчетный.Добавить();
				//Дт 90.02 Кт 41.01
				Движение.Период = Дата;
				Движение.СчетДт = ПланыСчетов.Хозрасчетный.Себестоимость;
				Движение.СчетКт = ПланыСчетов.Хозрасчетный.ТоварыНаСкладах;
				Движение.КоличествоКт = мин(ОсталосьСписать, ВыборкаДетальныеЗаписи.КоличествоОстатокПоПартиям);
				Если Движение.КоличествоКт = ВыборкаНоменклатура.КоличествоОстатокПоВсем Тогда
					Движение.Сумма  = ВыборкаНоменклатура.СуммаОстатокПоВсем;
				Иначе
					Движение.Сумма = Себестоимость * Движение.КоличествоКт;
				КонецЕсли;
				Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
				Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
				Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Склады] = Склад;
				Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Партии] = ВыборкаДетальныеЗаписи.Партия;
				ОсталосьСписать = ОсталосьСписать - Движение.КоличествоКт;
			КонецЦикла;
		КонецЕсли;	
	КонецЦикла; 
	
	// регистр Хозрасчетный 
	Движение = Движения.Хозрасчетный.Добавить();
	//Дт 62.01 Кт 90.01
	Движение.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыСПокупателями;
	Движение.СчетКт = ПланыСчетов.Хозрасчетный.Выручка;
	Движение.Период = Дата;
	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Контрагенты] = Покупатель;
	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Договоры] = Договор;
	Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Контрагенты] = Покупатель;
	Движение.Сумма = СуммаПоДокументу * Курс;
	
	
КонецПроцедуры

