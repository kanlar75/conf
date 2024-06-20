﻿
&НаСервере
Функция ЦенаРеализацииНоменклатурыНаСервере(Номенклатура)
	
	Возврат ПолучениеДанныхНаСервере.ЦенаНоменклатурыНаСервере(Номенклатура, Объект.ВидЦены, Объект.Дата); 
	 
КонецФункции

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент)
	
	ТекСтрока = Элементы.Товары.ТекущиеДанные;
	ОбработкаТабличнойЧастиКлиент.РассчитатьСуммуВСтроке(ТекСтрока);
	Объект.СуммаПоДокументу = Объект.Товары.Итог("Стоимость");
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаРеализацииПриИзменении(Элемент)
	
	ТекСтрока = Элементы.Товары.ТекущиеДанные;
	ОбработкаТабличнойЧастиКлиент.РассчитатьСуммуВСтроке(ТекСтрока);
	Объект.СуммаПоДокументу = Объект.Товары.Итог("Стоимость");
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыНоменклатураПриИзменении(Элемент)
	
	ТекСтрока = Элементы.Товары.ТекущиеДанные;
	Если ТекСтрока <> Неопределено Тогда
		Если Объект.Валюта = ПредопределенноеЗначение("Справочник.Валюты.Рубль") ИЛИ НЕ ЗначениеЗаполнено(Объект.Валюта) Тогда
			ТекСтрока.Цена = ЦенаРеализацииНоменклатурыНаСервере(ТекСтрока.Номенклатура);
			ОбработкаТабличнойЧастиКлиент.РассчитатьСуммуВСтроке(ТекСтрока);
			Объект.СуммаПоДокументу = Объект.Товары.Итог("Стоимость");
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.Автор) Тогда
		Объект.Автор = ПараметрыСеанса.ТекущийПользователь;	
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьПодбор(Команда)
	
	ПарамерыФормы = Новый Структура;
	ПарамерыФормы.Вставить("СкладПараметр", Объект.Склад);
	ПарамерыФормы.Вставить("ВидЦеныПараметр", Объект.ВидЦены);
	ПарамерыФормы.Вставить("ЗакрыватьПриВыборе", Ложь);
	ПарамерыФормы.Вставить("МножественныйВыбор", Истина);
	ПарамерыФормы.Вставить("АдресВХ", ПоместитьТЧТоварыВВременноеХранилище());
	ОткрытьФорму("Справочник.Номенклатура.Форма.ФормаПодбора", ПарамерыФормы, ЭтаФорма); 
	
КонецПроцедуры

&НаСервере
Функция ПоместитьТЧТоварыВВременноеХранилище()
	
	Возврат ПоместитьВоВременноеХранилище(Объект.Товары.Выгрузить());
	
КонецФункции 

&НаКлиенте
Процедура ОбработатьПодбор(АдресВХ) Экспорт

	ОбработатьПодборНаСервере(АдресВХ);
	Объект.СуммаПоДокументу = Объект.Товары.Итог("Стоимость");
	Модифицированность = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьПодборНаСервере(АдресВХ) 

	Объект.Товары.Загрузить(ПолучитьИзВременногоХранилища(АдресВХ));
	
КонецПроцедуры

&НаСервере
Процедура ВидЦеныПриИзмененииНаСервере()
			
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
		|	СУММА(ЗаказКлиентаТовары.Количество) КАК Количество
		|ПОМЕСТИТЬ ВТ_ТЧТовары
		|ИЗ
		|	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
		|ГДЕ
		|	ЗаказКлиентаТовары.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ЗаказКлиентаТовары.Номенклатура
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ТЧТовары.Номенклатура КАК Номенклатура,
		|	ВТ_ТЧТовары.Количество КАК Количество,
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0) КАК Цена
		|ИЗ
		|	ВТ_ТЧТовары КАК ВТ_ТЧТовары
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
		|				&Дата,
		|				ВидЦены = &ВидЦены
		|					И Номенклатура В
		|						(ВЫБРАТЬ
		|							ВТ_ТЧТовары.Номенклатура КАК Номенклатура
		|						ИЗ
		|							ВТ_ТЧТовары КАК ВТ_ТЧТовары)) КАК ЦеныНоменклатурыСрезПоследних
		|		ПО ВТ_ТЧТовары.Номенклатура = ЦеныНоменклатурыСрезПоследних.Номенклатура";
	
	Запрос.УстановитьПараметр("ВидЦены", Объект.ВидЦены);
	Запрос.УстановитьПараметр("Дата", Объект.Дата);
	Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		НоваяСтрока = Объект.Товары.Добавить();
		НоваяСтрока.Номенклатура = Выборка.Номенклатура;
		НоваяСтрока.Количество = Выборка.Количество;
		НоваяСтрока.Цена = Выборка.Цена;
		НоваяСтрока.Стоимость = Выборка.Количество * Выборка.Цена;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ВидЦеныПриИзменении(Элемент)
	Объект.Товары.Очистить();
	ВидЦеныПриИзмененииНаСервере();
КонецПроцедуры





