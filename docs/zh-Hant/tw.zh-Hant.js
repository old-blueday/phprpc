//
// Please note:
//
// * This code is designed to be readable but for compactness it only includes brief comments. You can see fuller comments
//   in the project Subversion repository at http://svn.tiddlywiki.org/Trunk/core/
//
// * You should never need to modify this source code directly. TiddlyWiki is carefully designed to allow deep customisation
//   without changing the core code. Please consult the development group at http://groups.google.com/group/TiddlyWikiDev
//

//--
//-- Configuration repository
//--

// Miscellaneous options
var config = {
	numRssItems: 20, // Number of items in the RSS feed
	animDuration: 400, // Duration of UI animations in milliseconds
	cascadeFast: 20, // Speed for cascade animations (higher == slower)
	cascadeSlow: 60, // Speed for EasterEgg cascade animations
	cascadeDepth: 5, // Depth of cascade animation
	locale: "zh-Hant" // W3C language tag
};

// Hashmap of alternative parsers for the wikifier
config.parsers = {};

// Adaptors
config.adaptors = {};
config.defaultAdaptor = null;

// Backstage tasks
config.tasks = {};

// Annotations
config.annotations = {};

// Custom fields to be automatically added to new tiddlers
config.defaultCustomFields = {};

// Messages
config.messages = {
	messageClose: {},
	dates: {},
	tiddlerPopup: {}
};

// Options that can be set in the options panel and/or cookies
config.options = {
	chkRegExpSearch: false,
	chkCaseSensitiveSearch: false,
	chkIncrementalSearch: true,
	chkAnimate: true,
	chkSaveBackups: true,
	chkAutoSave: false,
	chkGenerateAnRssFeed: false,
	chkSaveEmptyTemplate: false,
	chkOpenInNewWindow: true,
	chkToggleLinks: false,
	chkHttpReadOnly: true,
	chkForceMinorUpdate: false,
	chkConfirmDelete: true,
	chkInsertTabs: false,
	chkUsePreForStorage: true, // Whether to use <pre> format for storage
	chkDisplayInstrumentation: false,
	txtBackupFolder: "",
	txtEditorFocus: "text",
	txtMainTab: "tabTimeline",
	txtMoreTab: "moreTabAll",
	txtMaxEditRows: "30",
	txtFileSystemCharSet: "UTF-8",
	txtTheme: ""
	};
config.optionsDesc = {};

// Default tiddler templates
var DEFAULT_VIEW_TEMPLATE = 1;
var DEFAULT_EDIT_TEMPLATE = 2;
config.tiddlerTemplates = {
	1: "ViewTemplate",
	2: "EditTemplate"
};

// More messages (rather a legacy layout that should not really be like this)
config.views = {
	wikified: {
		tag: {}
	},
	editor: {
		tagChooser: {}
	}
};

// Backstage tasks
config.backstageTasks = ["save","sync","importTask","tweak","upgrade","plugins"];

// Macros; each has a 'handler' member that is inserted later
config.macros = {
	today: {},
	version: {},
	search: {sizeTextbox: 15},
	tiddler: {},
	tag: {},
	tags: {},
	tagging: {},
	timeline: {},
	allTags: {},
	list: {
		all: {},
		missing: {},
		orphans: {},
		shadowed: {},
		touched: {},
		filter: {}
	},
	closeAll: {},
	permaview: {},
	saveChanges: {},
	slider: {},
	option: {},
	options: {},
	newTiddler: {},
	newJournal: {},
	tabs: {},
	gradient: {},
	message: {},
	view: {defaultView: "text"},
	edit: {},
	tagChooser: {},
	toolbar: {},
	plugins: {},
	refreshDisplay: {},
	importTiddlers: {},
	upgrade: {
		source: "http://www.tiddlywiki.com/upgrade/",
		backupExtension: "pre.core.upgrade"
	},
	sync: {},
	annotations: {}
};

// Commands supported by the toolbar macro
config.commands = {
	closeTiddler: {},
	closeOthers: {},
	editTiddler: {},
	saveTiddler: {hideReadOnly: true},
	cancelTiddler: {},
	deleteTiddler: {hideReadOnly: true},
	permalink: {},
	references: {type: "popup"},
	jump: {type: "popup"},
	syncing: {type: "popup"},
	fields: {type: "popup"}
};

// Browser detection... In a very few places, there's nothing else for it but to know what browser we're using.
config.userAgent = navigator.userAgent.toLowerCase();
config.browser = {
	isIE: config.userAgent.indexOf("msie") != -1 && config.userAgent.indexOf("opera") == -1,
	isGecko: config.userAgent.indexOf("gecko") != -1,
	ieVersion: /MSIE (\d.\d)/i.exec(config.userAgent), // config.browser.ieVersion[1], if it exists, will be the IE version string, eg "6.0"
	isSafari: config.userAgent.indexOf("applewebkit") != -1,
	isBadSafari: !((new RegExp("[\u0150\u0170]","g")).test("\u0150")),
	firefoxDate: /gecko\/(\d{8})/i.exec(config.userAgent), // config.browser.firefoxDate[1], if it exists, will be Firefox release date as "YYYYMMDD"
	isOpera: config.userAgent.indexOf("opera") != -1,
	isLinux: config.userAgent.indexOf("linux") != -1,
	isUnix: config.userAgent.indexOf("x11") != -1,
	isMac: config.userAgent.indexOf("mac") != -1,
	isWindows: config.userAgent.indexOf("win") != -1
};

// Basic regular expressions
config.textPrimitives = {
	upperLetter: "[A-Z\u00c0-\u00de\u0150\u0170]",
	lowerLetter: "[a-z0-9_\\-\u00df-\u00ff\u0151\u0171]",
	anyLetter:   "[A-Za-z0-9_\\-\u00c0-\u00de\u00df-\u00ff\u0150\u0170\u0151\u0171]",
	anyLetterStrict: "[A-Za-z0-9\u00c0-\u00de\u00df-\u00ff\u0150\u0170\u0151\u0171]"
};
if(config.browser.isBadSafari) {
	config.textPrimitives = {
		upperLetter: "[A-Z\u00c0-\u00de]",
		lowerLetter: "[a-z0-9_\\-\u00df-\u00ff]",
		anyLetter:   "[A-Za-z0-9_\\-\u00c0-\u00de\u00df-\u00ff]",
		anyLetterStrict: "[A-Za-z0-9\u00c0-\u00de\u00df-\u00ff]"
	};
}
config.textPrimitives.sliceSeparator = "::";
config.textPrimitives.sectionSeparator = "##";
config.textPrimitives.urlPattern = "(?:file|http|https|mailto|ftp|irc|news|data):[^\\s'\"]+(?:/|\\b)";
config.textPrimitives.unWikiLink = "~";
config.textPrimitives.wikiLink = "(?:(?:" + config.textPrimitives.upperLetter + "+" +
	config.textPrimitives.lowerLetter + "+" +
	config.textPrimitives.upperLetter +
	config.textPrimitives.anyLetter + "*)|(?:" +
	config.textPrimitives.upperLetter + "{2,}" +
	config.textPrimitives.lowerLetter + "+))";

config.textPrimitives.cssLookahead = "(?:(" + config.textPrimitives.anyLetter + "+)\\(([^\\)\\|\\n]+)(?:\\):))|(?:(" + config.textPrimitives.anyLetter + "+):([^;\\|\\n]+);)";
config.textPrimitives.cssLookaheadRegExp = new RegExp(config.textPrimitives.cssLookahead,"mg");

config.textPrimitives.brackettedLink = "\\[\\[([^\\]]+)\\]\\]";
config.textPrimitives.titledBrackettedLink = "\\[\\[([^\\[\\]\\|]+)\\|([^\\[\\]\\|]+)\\]\\]";
config.textPrimitives.tiddlerForcedLinkRegExp = new RegExp("(?:" + config.textPrimitives.titledBrackettedLink + ")|(?:" +
	config.textPrimitives.brackettedLink + ")|(?:" +
	config.textPrimitives.urlPattern + ")","mg");
config.textPrimitives.tiddlerAnyLinkRegExp = new RegExp("("+ config.textPrimitives.wikiLink + ")|(?:" +
	config.textPrimitives.titledBrackettedLink + ")|(?:" +
	config.textPrimitives.brackettedLink + ")|(?:" +
	config.textPrimitives.urlPattern + ")","mg");

config.glyphs = {
	browsers: [
		function() {return config.browser.isIE;},
		function() {return true;}
	],
	currBrowser: null,
	codes: {
		downTriangle: ["\u25BC","\u25BE"],
		downArrow: ["\u2193","\u2193"],
		bentArrowLeft: ["\u2190","\u21A9"],
		bentArrowRight: ["\u2192","\u21AA"]
	}
};

//--
//-- Shadow tiddlers
//--

config.shadowTiddlers = {
	StyleSheet: "",
	MarkupPreHead: "",
	MarkupPostHead: "",
	MarkupPreBody: "",
	MarkupPostBody: "",
	TabTimeline: '<<timeline>>',
	TabAll: '<<list all>>',
	TabTags: '<<allTags excludeLists>>',
	TabMoreMissing: '<<list missing>>',
	TabMoreOrphans: '<<list orphans>>',
	TabMoreShadowed: '<<list shadowed>>',
	AdvancedOptions: '<<options>>',
	PluginManager: '<<plugins>>',
	ToolbarCommands: '|~ViewToolbar|closeTiddler closeOthers +editTiddler > fields syncing permalink references jump|\n|~EditToolbar|+saveTiddler -cancelTiddler deleteTiddler|'
};

// zh-Hant ConfigTweaks
/*{{{*/
config.options.txtFileSystemCharSet = "UTF-8";
/*}}}*/
// -End of ConfigTweak
/***
|''Name:''|zh-HantTranslationPlugin|
|''Description:''|Translation of TiddlyWiki into Traditional Chinese|
|''Source:''|http://tiddlywiki-zh.googlecode.com/svn/trunk/|
|''Subversion:''|http://svn.tiddlywiki.org/Trunk/association/locales/core/zh-Hant/locale.zh-Hant.js|
|''Author:''|BramChen (bram.chen (at) gmail (dot) com)|
|''Version:''|2.4.1|
|''Date:''|Jul 28, 2008|
|''Comments:''|Please make comments at http://groups-beta.google.com/group/TiddlyWiki-zh/|
|''License:''|[[Creative Commons Attribution-ShareAlike 2.5 License|http://creativecommons.org/licenses/by-sa/2.5/]]|
|''~CoreVersion:''|2.4.1|
***/

//{{{
// --
// -- Translateable strings
// --

// Strings in "double quotes" should be translated; strings in 'single quotes' should be left alone

if (config.options.txtUserName == 'YourName' || !config.options.txtUserName) // do not translate this line, but do translate the next line
	merge(config.options,{txtUserName: "Ma Bingyao"});

merge(config.tasks,{
	save: {text: "儲存", tooltip: "儲存變更至此 TiddlyWiki", action: saveChanges},
	sync: {text: "同步", tooltip: "將你的資料內容與外部伺服器與檔案同步", content: '<<sync>>'},
	importTask: {text: "導入", tooltip: "自其他檔案或伺服器導入文章或套件", content: '<<importTiddlers>>'},
	tweak: {text: "選項", tooltip: "改變此 TiddlyWiki 的顯示與行為的設定", content: '<<options>>'},
	upgrade: {text: "更新", tooltip: "更新 TiddlyWiki 核心程式", content: '<<upgrade>>'},
	plugins: {text: "套件管理", tooltip: "管理已安裝的套件", content: '<<plugins>>'}
});

merge(config.optionsDesc,{
	txtUserName: "編輯文章所使用之作者署名",
	chkRegExpSearch: "啟用正規式搜尋",
	chkCaseSensitiveSearch: "搜尋時，區分大小寫",
	chkIncrementalSearch: "隨打即找搜尋",
	chkAnimate: "使用動畫顯示",
	chkSaveBackups: "儲存變更前，保留備份檔案",
	chkAutoSave: "自動儲存變更",
	chkGenerateAnRssFeed: "儲存變更時，也儲存 RSS feed",
	chkSaveEmptyTemplate: "儲存變更時，也儲存空白範本",
	chkOpenInNewWindow: "於新視窗開啟連結",
	chkToggleLinks: "點擊已開啟文章連結時，將其關閉",
	chkHttpReadOnly: "非本機瀏覽文件時，隱藏編輯功能",
	chkForceMinorUpdate: "修改文章時，不變更作者名稱與日期時間",
	chkConfirmDelete: "刪除文章前須確認",
	chkInsertTabs: "使用 tab 鍵插入定位字元，而非跳至下一個欄位",
	txtBackupFolder: "存放備份檔案的資料夾",
	txtMaxEditRows: "編輯模式中顯示列數",
	txtFileSystemCharSet: "指定儲存文件所在之檔案系統之字集 (僅適用於 Firefox/Mozilla only)"});

// Messages
merge(config.messages,{
	customConfigError: "套件載入發生錯誤，詳細請參考 PluginManager",
	pluginError: "發生錯誤: %0",
	pluginDisabled: "未執行，因標籤設為 'systemConfigDisable'",
	pluginForced: "已執行，因標籤設為 'systemConfigForce'",
	pluginVersionError: "未執行，套件需較新版本的 TiddlyWiki",
	nothingSelected: "尚未作任何選擇，至少需選擇一項",
	savedSnapshotError: "此 TiddlyWiki 未正確存檔，詳見 http://www.tiddlywiki.com/#DownloadSoftware",
	subtitleUnknown: "(未知)",
	undefinedTiddlerToolTip: "'%0' 尚無內容",
	shadowedTiddlerToolTip: "'%0' 尚無內容, 但已定義隱藏的預設值",
	tiddlerLinkTooltip: "%0 - %1, %2",
	externalLinkTooltip: "外部連結至 %0",
	noTags: "未設定標籤的文章",
	notFileUrlError: "須先將此 TiddlyWiki 存至檔案，才可儲存變更",
	cantSaveError: "無法儲存變更。可能的原因有：\n- 你的瀏覽器不支援此儲存功能（Firefox, Internet Explorer, Safari and Opera 經適當設定後可儲存變更）\n- 也可能是你的 TiddlyWiki 檔名包含不合法的字元所致。\n- 或是 TiddlyWiki 文件被改名或搬移。",
	invalidFileError: " '%0' 非有效之 TiddlyWiki 文件",
	backupSaved: "已儲存備份",
	backupFailed: "無法儲存備份",
	rssSaved: "RSS feed 已儲存",
	rssFailed: "無法儲存 RSS feed ",
	emptySaved: "已儲存範本",
	emptyFailed: "無法儲存範本",
	mainSaved: "主要的TiddlyWiki已儲存",
	mainFailed: "無法儲存主要 TiddlyWiki，所作的改變未儲存",
	macroError: "巨集 <<\%0>> 執行錯誤",
	macroErrorDetails: "執行巨集 <<\%0>> 時，發生錯誤 :\n%1",
	missingMacro: "無此巨集",
	overwriteWarning: "'%0' 已存在，[確定]覆寫之",
	unsavedChangesWarning: "注意！ 尚未儲存變更\n\n[確定]存檔，或[取消]放棄存檔？",
	confirmExit: "--------------------------------\n\nTiddlyWiki 以更改內容尚未儲存，繼續的話將遺失這些更動\n\n--------------------------------",
	saveInstructions: "SaveChanges",
	unsupportedTWFormat: "未支援此 TiddlyWiki 格式：'%0'",
	tiddlerSaveError: "儲存文章 '%0' 時，發生錯誤。",
	tiddlerLoadError: "載入文章 '%0' 時，發生錯誤。",
	wrongSaveFormat: "無法使用格式 '%0' 儲存，請使用標准格式存放",
	invalidFieldName: "無效的欄位名稱：%0",
	fieldCannotBeChanged: "無法變更欄位：'%0'",
	loadingMissingTiddler: "正從伺服器 '%1' 的：\n\n工作區 '%3' 中的 '%2' 擷取文章 '%0'",
	upgradeDone: "已更新至 %0 版\n\n點擊 '確定' 重新載入更新後的 TiddlyWiki"});

merge(config.messages.messageClose,{
	text: "關閉",
	tooltip: "關閉此訊息"});

merge(config.messages,{
	backstage: {
		open: {text: "控制台", tooltip: "開啟控制台執行編寫工作"},
		close: {text: "關閉", tooltip: "關閉控制台"},
		prompt: "控制台：",
		decal: {
			edit: {text: "編輯", tooltip: "編輯 '%0'"}
		}}});

merge(config.messages,{
	listView: {
		tiddlerTooltip: "檢視全文",
		previewUnavailable: "(無法預覽)"}});

merge(config.messages,{
	dates: {
	months: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
	days: ["星期日", "星期一","星期二", "星期三", "星期四", "星期五", "星期六"],
	shortMonths: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"],
	shortDays: ["日", "一","二", "三", "四", "五", "六"],
	daySuffixes: ["st","nd","rd","th","th","th","th","th","th","th",
		"th","th","th","th","th","th","th","th","th","th",
		"st","nd","rd","th","th","th","th","th","th","th",
		"st"],
	am: "上午",
	pm: "下午"}});

merge(config.messages.tiddlerPopup,{
	});

merge(config.views.wikified.tag,{
	labelNoTags: "未設標籤",
	labelTags: "標籤: ",
	openTag: "開啟標籤 '%0'",
	tooltip: "顯示標籤為 '%0' 的文章",
	openAllText: "開啟以下所有文章",
	openAllTooltip: "開啟以下所有文章",
	popupNone: "僅此文標籤為 '%0'"});

merge(config.views.wikified,{
	defaultText: "",
	defaultModifier: "(未完成)",
	shadowModifier: "(預設)",
	dateFormat: "YYYY年0MM月0DD日",
	createdPrompt: "建立於"});

merge(config.views.editor,{
	tagPrompt: "設定標籤之間以空白區隔，[[標籤含空白時請使用雙中括弧]]，或點選現有之標籤加入",
	defaultText: ""});

merge(config.views.editor.tagChooser,{
	text: "標籤",
	tooltip: "點選現有之標籤加至本文章",
	popupNone: "未設定標籤",
	tagTooltip: "加入標籤 '%0'"});

merge(config.messages,{
	sizeTemplates:
		[
		{unit: 1024*1024*1024, template: "%0\u00a0GB"},
		{unit: 1024*1024, template: "%0\u00a0MB"},
		{unit: 1024, template: "%0\u00a0KB"},
		{unit: 1, template: "%0\u00a0B"}
		]});

merge(config.macros.search,{
	label: " 尋找",
	prompt: "搜尋本 Wiki",
	accessKey: "F",
	successMsg: " %0 篇符合條件: %1",
	failureMsg: " 無符合條件: %0"});

merge(config.macros.tagging,{
	label: "引用標籤:",
	labelNotTag: "無引用標籤",
	tooltip: "列出標籤為 '%0' 的文章"});

merge(config.macros.timeline,{
	dateFormat: "YYYY年0MM月0DD日"});

merge(config.macros.allTags,{
	tooltip: "顯示文章- 標籤為'%0'",
	noTags: "沒有標籤"});

config.macros.list.all.prompt = "依字母排序";
config.macros.list.missing.prompt = "被引用且內容空白的文章";
config.macros.list.orphans.prompt = "未被引用的文章";
config.macros.list.shadowed.prompt = "這些隱藏的文章已預設內容";
config.macros.list.touched.prompt = "自下載或新增後被修改過的文章";

merge(config.macros.closeAll,{
	label: "全部關閉",
	prompt: "關閉所有開啟中的 tiddler (編輯中除外)"});

merge(config.macros.permaview,{
	label: "引用連結",
	prompt: "可存取現有開啟之文章的連結位址"});

merge(config.macros.saveChanges,{
	label: "儲存變更",
	prompt: "儲存所有文章，產生新的版本",
	accessKey: "S"});

merge(config.macros.newTiddler,{
	label: "新增文章",
	prompt: "新增 tiddler",
	title: "新增文章",
	accessKey: "N"});

merge(config.macros.newJournal,{
	label: "新增日誌",
	prompt: "新增 jounal",
	accessKey: "J"});

merge(config.macros.options,{
	wizardTitle: "增訂的進階選項",
	step1Title: "增訂的選項儲存於瀏覽器的 cookies",
	step1Html: "<input type='hidden' name='markList'></input><br><input type='checkbox' checked='false' name='chkUnknown'>顯示未知選項</input>",
	unknownDescription: "//(未知)//",
	listViewTemplate: {
		columns: [
			{name: 'Option', field: 'option', title: "選項", type: 'String'},
			{name: 'Description', field: 'description', title: "說明", type: 'WikiText'},
			{name: 'Name', field: 'name', title: "名稱", type: 'String'}
			],
		rowClasses: [
			{className: 'lowlight', field: 'lowlight'}
			]}
	});

merge(config.macros.plugins,{
	wizardTitle: "擴充套件管理",
	step1Title: "- 已載入之套件",
	step1Html: "<input type='hidden' name='markList'></input>", // DO NOT TRANSLATE
	skippedText: "(此套件因剛加入，故尚未執行)",
	noPluginText: "未安裝套件",
	confirmDeleteText: "確認是否刪除所選套件:\n\n%0",
	removeLabel: "移除 systemConfig 標籤",
	removePrompt: "移除 systemConfig 標籤",
	deleteLabel: "刪除",
	deletePrompt: "永遠刪除所選套件",

	listViewTemplate : {
		columns: [
			{name: 'Selected', field: 'Selected', rowName: 'title', type: 'Selector'},
			{name: 'Tiddler', field: 'tiddler', title: "套件", type: 'Tiddler'},
			{name: 'Size', field: 'size', tiddlerLink: 'size', title: "大小", type: 'Size'},
			{name: 'Forced', field: 'forced', title: "強制執行", tag: 'systemConfigForce', type: 'TagCheckbox'},
			{name: 'Disabled', field: 'disabled', title: "停用", tag: 'systemConfigDisable', type: 'TagCheckbox'},
			{name: 'Executed', field: 'executed', title: "已載入", type: "Boolean", trueText: "是", falseText: "否"},
			{name: 'Startup Time', field: 'startupTime', title: "載入時間", type: 'String'},
			{name: 'Error', field: 'error', title: "載入狀態", type: 'Boolean', trueText: "錯誤", falseText: "正常"},
			{name: 'Log', field: 'log', title: "紀錄", type: 'StringList'}
			],
		rowClasses: [
			{className: 'error', field: 'error'},
			{className: 'warning', field: 'warning'}
			]}
	});

merge(config.macros.toolbar,{
	moreLabel: "其他",
	morePrompt: "顯示更多工具命令"});

merge(config.macros.refreshDisplay,{
	label: "刷新",
	prompt: "刷新此 TiddlyWiki 顯示"
	});

merge(config.macros.importTiddlers,{
	readOnlyWarning: "TiddlyWiki 於唯讀模式下，不支援導入文章。請由本機（file://）開啟 TiddlyWiki 文件",
	wizardTitle: "自其他檔案或伺服器導入文章",
	step1Title: "步驟一：指定伺服器或來源文件",
	step1Html: "指定伺服器類型：<select name='selTypes'><option value=''>選取...</option></select><br>請輸入網址或路徑：<input type='text' size=50 name='txtPath'><br>...或選擇來源文件：<input type='file' size=50 name='txtBrowse'><br><hr>...或選擇指定的饋入來源：<select name='selFeeds'><option value=''>選取...</option></select>",
	openLabel: "開啟",
	openPrompt: "開啟檔案或",
	openError: "讀取來源文件時發生錯誤",
	statusOpenHost: "正與伺服器建立連線",
	statusGetWorkspaceList: "正在取得可用之文章清單",
	errorGettingTiddlerList: "取得文章清單時發生錯誤，請點選「取消」後重試。",
	step2Title: "步驟二：選擇工作區",
	step2Html: "輸入工作區名稱：<input type='text' size=50 name='txtWorkspace'><br>...或選擇工作區：<select name='selWorkspace'><option value=''>選取...</option></select>",
	cancelLabel: "取消",
	cancelPrompt: "取消本次導入動作",
	statusOpenWorkspace: "正在開啟工作區",
	statusGetTiddlerList: "正在取得可用之文章清單",
	step3Title: "步驟三：選擇欲導入之文章",
	step3Html: "<input type='hidden' name='markList'></input><br><input type='checkbox' checked='true' name='chkSync'>保持這些文章與伺服器的連結，便於同步後續的變更。</input><br><input type='checkbox' name='chkSave'>儲存此伺服器的詳細資訊於標籤為 'systemServer' 的文章名為：</input> <input type='text' size=25 name='txtSaveTiddler'>",
	importLabel: "導入",
	importPrompt: "導入所選文章",
	confirmOverwriteText: "確定要覆寫這些文章：\n\n%0",
	step4Title: "步驟四：正在導入%0 篇文章",
	step4Html: "<input type='hidden' name='markReport'></input>", // DO NOT TRANSLATE
	doneLabel: "完成",
	donePrompt: "關閉",
	statusDoingImport: "正在導入文章 ...",
	statusDoneImport: "所選文章已導入",
	systemServerNamePattern: "%2 位於 %1",
	systemServerNamePatternNoWorkspace: "%1",
	confirmOverwriteSaveTiddler: "此 tiddler '%0' 已經存在。點擊「確定」以伺服器上料覆寫之，或「取消」不變更後離開",
	serverSaveTemplate: "|''Type:''|%0|\n|''網址：''|%1|\n|''工作區：''|%2|\n\n此文為自動產生紀錄伺服器之相關資訊。",
	serverSaveModifier: "（系統）",

	listViewTemplate: {
		columns: [
			{name: 'Selected', field: 'Selected', rowName: 'title', type: 'Selector'},
			{name: 'Tiddler', field: 'tiddler', title: "文章", type: 'Tiddler'},
			{name: 'Size', field: 'size', tiddlerLink: 'size', title: "大小", type: 'Size'},
			{name: 'Tags', field: 'tags', title: "標籤", type: 'Tags'}
			],
		rowClasses: [
			]}
	});

merge(config.macros.upgrade,{
	wizardTitle: "更新 TiddlyWiki 核心程式",
	step1Title: "更新或修補此 TiddlyWiki 至最新版本",
	step1Html: "您將更新至最新版本的 TiddlyWiki 核心程式 (自 <a href='%0' class='externalLink' target='_blank'>%1</a>)。 在更新過程中，您的資料將被保留。<br><br>請注意：更新核心可能不相容於其他套件。若對更新的檔案有問題，詳見 <a href='http://www.tiddlywiki.org/wiki/CoreUpgrades' class='externalLink' target='_blank'>http://www.tiddlywiki.org/wiki/CoreUpgrades</a>",
	errorCantUpgrade: "j無法更新此 TiddlyWiki. 您只能自本機端的 TiddlyWiki 檔案執行更新程序",
	errorNotSaved: "執行更新之前，請先儲存變更",
	step2Title: "確認更新步驟",
	step2Html_downgrade: "您的 TiddlyWiki 將自 %1 版降級至 %0版。<br><br>不建議降級至較舊的版本。",
	step2Html_restore: "此 TiddlyWiki 核心已是最新版 (%0)。<br><br>您可以繼續更新作業以確認核心程式未曾毀損。",
	step2Html_upgrade: "您的 TiddlyWiki 将自 %1 版更新至 %0 版",
	upgradeLabel: "更新",
	upgradePrompt: "準備更新作業",
	statusPreparingBackup: "準備備份中",
	statusSavingBackup: "備份檔案",
	errorSavingBackup: "備份檔案時發生問題",
	statusLoadingCore: "核心程式載入中",
	errorLoadingCore: "載入核心程式時，發生錯誤",
	errorCoreFormat: "新版核心程式發生錯誤",
	statusSavingCore: "正在儲存新版核心程式",
	statusReloadingCore: "新版核心程式載入中",
	startLabel: "開始",
	startPrompt: "開始更新作業",
	cancelLabel: "取消",
	cancelPrompt: "取消更新作業",
	step3Title: "已取消更新作業",
	step3Html: "您已取消更新作業"
	});

merge(config.macros.sync,{
	listViewTemplate: {
		columns: [
			{name: 'Selected', field: 'selected', rowName: 'title', type: 'Selector'},
			{name: 'Tiddler', field: 'tiddler', title: "文章", type: 'Tiddler'},
			{name: 'Server Type', field: 'serverType', title: "伺服器類型", type: 'String'},
			{name: 'Server Host', field: 'serverHost', title: "伺服器主機", type: 'String'},
			{name: 'Server Workspace', field: 'serverWorkspace', title: "伺服器工作區", type: 'String'},
			{name: 'Status', field: 'status', title: "同步情形", type: 'String'},
			{name: 'Server URL', field: 'serverUrl', title: "伺服器網址", text: "View", type: 'Link'}
			],
		rowClasses: [
			],
		buttons: [
			{caption: "同步更新這些文章", name: 'sync'}
			]},
	wizardTitle: "將你的資料內容與外部伺服器與檔案同步",
	step1Title: "選擇欲同步的文章",
	step1Html: '<input type="hidden" name="markList"></input>', // DO NOT TRANSLATE
	syncLabel: "同步",
	syncPrompt: "同步更新這些文章",
	hasChanged: "已更動",
	hasNotChanged: "未更動",
	syncStatusList: {
		none: {text: "...", display:null, className:'notChanged'},
		changedServer: {text: "伺服器資料已更動", display:null, className:'changedServer'},
		changedLocally: {text: "本機資料已更動", display:null, className:'changedLocally'},
		changedBoth: {text: "已同時更新本機與伺服器上的資料", display:null, className:'changedBoth'},
		notFound: {text: "伺服器無此資料", display:null, className:'notFound'},
		putToServer: {text: "已儲存更新資料至伺服器", display:null, className:'putToServer'},
		gotFromServer: {text: "已從伺服器擷取更新資料", display:null, className:'gotFromServer'}
		}
	});

merge(config.macros.annotations,{
	});

merge(config.commands.closeTiddler,{
	text: "關閉",
	tooltip: "關閉本文"});

merge(config.commands.closeOthers,{
	text: "關閉其他",
	tooltip: "關閉其他文章"});

merge(config.commands.editTiddler,{
	text: "編輯",
	tooltip: "編輯本文",
	readOnlyText: "檢視",
	readOnlyTooltip: "檢視本文之原始內容"});

merge(config.commands.saveTiddler,{
	text: "完成",
	tooltip: "確定修改"});

merge(config.commands.cancelTiddler,{
	text: "取消",
	tooltip: "取消修改",
	warning: "確定取消對 '%0' 的修改嗎?",
	readOnlyText: "完成",
	readOnlyTooltip: "返回正常顯示模式"});

merge(config.commands.deleteTiddler,{
	text: "刪除",
	tooltip: "刪除文章",
	warning: "確定刪除 '%0'?"});

merge(config.commands.permalink,{
	text: "引用連結",
	tooltip: "本文引用連結"});

merge(config.commands.references,{
	text: "引用",
	tooltip: "引用本文的文章",
	popupNone: "本文未被引用"});

merge(config.commands.jump,{
	text: "捲頁",
	tooltip: "捲頁至其他已開啟的文章"});

merge(config.commands.syncing,{
	text: "同步",
	tooltip: "本文章與伺服器或其他外部檔案的同步資訊",
	currentlySyncing: "<div>同步類型：<span class='popupHighlight'>'%0'</span></"+"div><div>與伺服器：<span class='popupHighlight'>%1 同步</span></"+"div><div>工作區：<span class='popupHighlight'>%2</span></"+"div>", // Note escaping of closing <div> tag
	notCurrentlySyncing: "無進行中的同步動作",
	captionUnSync: "停止同步此文章",
	chooseServer: "與其他伺服器同步此文章:",
	currServerMarker: "\u25cf ",
	notCurrServerMarker: "  "});

merge(config.commands.fields,{
	text: "欄位",
	tooltip: "顯示此文章的擴充資訊",
	emptyText: "此文章沒有擴充欄位",
	listViewTemplate: {
		columns: [
			{name: 'Field', field: 'field', title: "擴充欄位", type: 'String'},
			{name: 'Value', field: 'value', title: "內容", type: 'String'}
			],
		rowClasses: [
			],
		buttons: [
			]}});

merge(config.shadowTiddlers,{
	DefaultTiddlers: "GettingStarted",
    Footer: "[[魯 ICP 備 06029414 號|http://www.miibeian.gov.cn/]]\ncopyright &copy; phprpc.org",
	GettingStarted: "<<tiddler HideTiddlerTitle>>",
	MainMenu: "",
	OptionsPanel: "這些設定將暫存於瀏覽器\n請簽名<<option txtUserName>>\n (範例：WikiWord)\n\n <<option chkSaveBackups>> 儲存備份\n <<option chkAutoSave>> 自動儲存\n <<option chkRegExpSearch>> 正規式搜尋\n <<option chkCaseSensitiveSearch>> 區分大小寫搜尋\n <<option chkAnimate>> 使用動畫顯示\n----\n [[進階選項|AdvancedOptions]]",
	SiteTitle: "PHPRPC",
	SiteSubtitle: "perfect high performance remote procedure call",
	SiteUrl: 'http://www.phprpc.org/',
	SideBarOptions: '<<search>><<closeAll>><<permaview>><<newTiddler>><<newJournal " YYYY年0MM月0DD日" "日誌">><<saveChanges>><<slider chkSliderOptionsPanel OptionsPanel "偏好設定 \u00bb" "變更 TiddlyWiki 選項">>',
	SideBarTabs: '<<tabs txtMainTab "最近更新" "依更新日期排序" TabTimeline "全部" "所有文章" TabAll "分類" "所有標籤" TabTags "更多" "其他" TabMore>>',
	StyleSheet: '[[StyleSheetLocale]]\n[[StyleSheetSyntaxHighlighter]]\n[[StyleSheetPHPRPC]]',
	TabMore: '<<tabs txtMoreTab "未完成" "內容空白的文章" TabMoreMissing "未引用" "未被引用的文章" TabMoreOrphans "預設文章" "已預設內容的隱藏文章" TabMoreShadowed>>',
	ToolbarCommands: "|~ViewToolbar|closeTiddler closeOthers +editTiddler > fields syncing permalink references jump|\n|~EditToolbar|+saveTiddler -cancelTiddler deleteTiddler|",
    TopMenu: "* [[主頁|http://www.phprpc.org/zh_TW/]]\n* [[下載|http://www.phprpc.org/zh_TW/download]]\n* ''文檔''\n* [[博客|http://www.phprpc.org/blog]]\n* [[論壇|http://www.phprpc.org/forum]]"});

merge(config.annotations,{
	AdvancedOptions: "此預設文章可以存取一些進階選項。",
	ColorPalette: "此預設文章裡的設定值，將決定 ~TiddlyWiki 使用者介面的配色。",
	DefaultTiddlers: "當 ~TiddlyWiki 在瀏覽器中開啟時，此預設文章裡列出的文章，將被自動顯示。",
	EditTemplate: "此預設文章裡的 HTML template 將決定文章進入編輯模式時的顯示版面。",
	GettingStarted: "此預設文章提供基本的使用說明。",
	ImportTiddlers: "此預設文章提供存取導入中的文章。",
	MainMenu: "此預設文章的內容，為於螢幕左側主選單的內容",
	MarkupPreHead: "此文章的內容將加至 TiddlyWiki 文件的 <head> 段落的起始",
	MarkupPostHead: "此文章的內容將加至 TiddlyWiki 文件的 <head> 段落的最後",
	MarkupPreBody: "此文章的內容將加至 TiddlyWiki 文件的 <body> 段落的起始",
	MarkupPostBody: "此文章的內容將加至 TiddlyWiki 文件的 <body> 段落的最後，於 script 區塊之後",
	OptionsPanel: "此預設文章的內容，為於螢幕右側副選單中的選項面板裡的內容",
	PageTemplate: "此預設文章裡的 HTML template 決定的 ~TiddlyWiki 主要的版面配置",
	PluginManager: "此預設文章提供存取套件管理員",
	SideBarOptions: "此預設文章的內容，為於螢幕右側副選單中選項面板裡的內容",
	SideBarTabs: "此預設文章的內容，為於螢幕右側副選單中的頁籤面板裡的內容",
	SiteSubtitle: "此預設文章的內容為頁面的副標題",
	SiteTitle: "此預設文章的內容為頁面的主標題",
	SiteUrl: "此預設文章的內容須設定為文件發佈時的完整網址",
	StyleSheetColors: "此預設文章內含的 CSS 規則，為相關的頁面元素的配色。''勿修改此文''，請於 StyleSheet 中作增修",
	StyleSheet: "此預設文章內容可包含 CSS 規則",
	StyleSheetLayout: "此預設文章內含的 CSS 規則，為相關的頁面元素的版面配置。''勿修改此文''，請於 StyleSheet 中作增修",
	StyleSheetLocale: "此預設文章內含的 CSS 規則，可依翻譯語系做適當調整",
	StyleSheetPrint: "此預設文章內含的 CSS 規則，用於列印時的樣式",
	TabAll: "此預設文章的內容，為於螢幕右側副選單中的「全部」頁籤的內容",
	TabMore: "此預設文章的內容，為於螢幕右側副選單中的「更多」頁籤的內容",
	TabMoreMissing: "此預設文章的內容，為於螢幕右側副選單中的「未完成」頁籤的內容",
	TabMoreOrphans: "此預設文章的內容，為於螢幕右側副選單中的「未引用」頁籤的內容",
	TabMoreShadowed: "此預設文章的內容，為於螢幕右側副選單中的「預設文章」頁籤的內容",
	TabTags: "此預設文章的內容，為於螢幕右側副選單中的「分類」頁籤的內容",
	TabTimeline: "此預設文章的內容，為於螢幕右側副選單中的「最近更新」頁籤的內容",
	ToolbarCommands: "此預設文章的內容，為顯示於文章工具列之命令",
	ViewTemplate: "此預設文章裡的 HTML template 決定文章顯示的樣子"
	});
//}}}
config.shadowTiddlers['DateFormat'] = 'DateFormat: [[YYYY年0MM月0DD日 am hh12:0mm]]\nshortDateFormat: [[YYYY年0MM月0DD日]]';//--
//-- Main
//--

var params = null; // Command line parameters
var store = null; // TiddlyWiki storage
var story = null; // Main story
var formatter = null; // Default formatters for the wikifier
var anim = typeof Animator == "function" ? new Animator() : null; // Animation engine
var readOnly = false; // Whether we're in readonly mode
var highlightHack = null; // Embarrassing hack department...
var hadConfirmExit = false; // Don't warn more than once
var safeMode = false; // Disable all plugins and cookies
var showBackstage; // Whether to include the backstage area
var installedPlugins = []; // Information filled in when plugins are executed
var startingUp = false; // Whether we're in the process of starting up
var pluginInfo,tiddler; // Used to pass information to plugins in loadPlugins()

// Whether to use the JavaSaver applet
var useJavaSaver = (config.browser.isSafari || config.browser.isOpera) && (document.location.toString().substr(0,4) != "http");

// Starting up
function main()
{
	var t10,t9,t8,t7,t6,t5,t4,t3,t2,t1,t0 = new Date();
	startingUp = true;
	window.onbeforeunload = function(e) {if(window.confirmExit) return confirmExit();};
	params = getParameters();
	if(params)
		params = params.parseParams("open",null,false);
	store = new TiddlyWiki();
	invokeParamifier(params,"oninit");
	story = new Story("tiddlerDisplay","tiddler");
	addEvent(document,"click",Popup.onDocumentClick);
	saveTest();
	loadOptionsCookie();
	for(var s=0; s<config.notifyTiddlers.length; s++)
		store.addNotification(config.notifyTiddlers[s].name,config.notifyTiddlers[s].notify);
	t1 = new Date();
	loadShadowTiddlers();
	t2 = new Date();
	store.loadFromDiv("storeArea","store",true);
	t3 = new Date();
	invokeParamifier(params,"onload");
	t4 = new Date();
	readOnly = (window.location.protocol == "file:") ? false : config.options.chkHttpReadOnly;
	var pluginProblem = loadPlugins();
	t5 = new Date();
	formatter = new Formatter(config.formatters);
	invokeParamifier(params,"onconfig");
	story.switchTheme(config.options.txtTheme);
	showBackstage = !readOnly;
	t6 = new Date();
	store.notifyAll();
	t7 = new Date();
	restart();
	refreshDisplay();
	t8 = new Date();
	if(pluginProblem) {
		story.displayTiddler(null,"PluginManager");
		displayMessage(config.messages.customConfigError);
	}
	for(var m in config.macros) {
		if(config.macros[m].init)
			config.macros[m].init();
	}
	t9 = new Date();
	if(showBackstage)
		backstage.init();
	t10 = new Date();
	if(config.options.chkDisplayInstrumentation) {
		displayMessage("LoadShadows " + (t2-t1) + " ms");
		displayMessage("LoadFromDiv " + (t3-t2) + " ms");
		displayMessage("LoadPlugins " + (t5-t4) + " ms");
		displayMessage("Notify " + (t7-t6) + " ms");
		displayMessage("Restart " + (t8-t7) + " ms");
		displayMessage("Macro init " + (t9-t8) + " ms");
		displayMessage("Total: " + (t10-t0) + " ms");
	}
	startingUp = false;
}

// Restarting
function restart()
{
	invokeParamifier(params,"onstart");
	if(story.isEmpty()) {
		story.displayDefaultTiddlers();
	}
	window.scrollTo(0,0);
}

function saveTest()
{
	var s = document.getElementById("saveTest");
	if(s.hasChildNodes())
		alert(config.messages.savedSnapshotError);
	s.appendChild(document.createTextNode("savetest"));
}

function loadShadowTiddlers()
{
	var shadows = new TiddlyWiki();
	shadows.loadFromDiv("shadowArea","shadows",true);
	shadows.forEachTiddler(function(title,tiddler){config.shadowTiddlers[title] = tiddler.text;});
	delete shadows;
}

function loadPlugins()
{
	if(safeMode)
		return false;
	var tiddlers = store.getTaggedTiddlers("systemConfig");
	var toLoad = [];
	var nLoaded = 0;
	var map = {};
	var nPlugins = tiddlers.length;
	installedPlugins = [];
	for(var i=0; i<nPlugins; i++) {
		var p = getPluginInfo(tiddlers[i]);
		installedPlugins[i] = p;
		var n = p.Name;
		if(n)
			map[n] = p;
		n = p.Source;
		if(n)
			map[n] = p;
	}
	var visit = function(p) {
		if(!p || p.done)
			return;
		p.done = 1;
		var reqs = p.Requires;
		if(reqs) {
			reqs = reqs.readBracketedList();
			for(var i=0; i<reqs.length; i++)
				visit(map[reqs[i]]);
		}
		toLoad.push(p);
	};
	for(i=0; i<nPlugins; i++)
		visit(installedPlugins[i]);
	for(i=0; i<toLoad.length; i++) {
		p = toLoad[i];
		pluginInfo = p;
		tiddler = p.tiddler;
		if(isPluginExecutable(p)) {
			if(isPluginEnabled(p)) {
				p.executed = true;
				var startTime = new Date();
				try {
					if(tiddler.text)
						window.eval(tiddler.text);
					nLoaded++;
				} catch(ex) {
					p.log.push(config.messages.pluginError.format([exceptionText(ex)]));
					p.error = true;
				}
				pluginInfo.startupTime = String((new Date()) - startTime) + "ms";
			} else {
				nPlugins--;
			}
		} else {
			p.warning = true;
		}
	}
	return nLoaded != nPlugins;
}

function getPluginInfo(tiddler)
{
	var p = store.getTiddlerSlices(tiddler.title,["Name","Description","Version","Requires","CoreVersion","Date","Source","Author","License","Browsers"]);
	p.tiddler = tiddler;
	p.title = tiddler.title;
	p.log = [];
	return p;
}

// Check that a particular plugin is valid for execution
function isPluginExecutable(plugin)
{
	if(plugin.tiddler.isTagged("systemConfigForce")) {
		plugin.log.push(config.messages.pluginForced);
		return true;
	}
	if(plugin["CoreVersion"]) {
		var coreVersion = plugin["CoreVersion"].split(".");
		var w = parseInt(coreVersion[0],10) - version.major;
		if(w == 0 && coreVersion[1])
			w = parseInt(coreVersion[1],10) - version.minor;
		if(w == 0 && coreVersion[2])
			w = parseInt(coreVersion[2],10) - version.revision;
		if(w > 0) {
			plugin.log.push(config.messages.pluginVersionError);
			return false;
		}
	}
	return true;
}

function isPluginEnabled(plugin)
{
	if(plugin.tiddler.isTagged("systemConfigDisable")) {
		plugin.log.push(config.messages.pluginDisabled);
		return false;
	}
	return true;
}

function invokeMacro(place,macro,params,wikifier,tiddler)
{
	try {
		var m = config.macros[macro];
		if(m && m.handler)
			m.handler(place,macro,params.readMacroParams(),wikifier,params,tiddler);
		else
			createTiddlyError(place,config.messages.macroError.format([macro]),config.messages.macroErrorDetails.format([macro,config.messages.missingMacro]));
	} catch(ex) {
		createTiddlyError(place,config.messages.macroError.format([macro]),config.messages.macroErrorDetails.format([macro,ex.toString()]));
	}
}

//--
//-- Paramifiers
//--

function getParameters()
{
	var p = null;
	if(window.location.hash) {
		p = decodeURIComponent(window.location.hash.substr(1));
		if(config.browser.firefoxDate != null && config.browser.firefoxDate[1] < "20051111")
			p = convertUTF8ToUnicode(p);
	}
	return p;
}

function invokeParamifier(params,handler)
{
	if(!params || params.length == undefined || params.length <= 1)
		return;
	for(var t=1; t<params.length; t++) {
		var p = config.paramifiers[params[t].name];
		if(p && p[handler] instanceof Function)
			p[handler](params[t].value);
	}
}

config.paramifiers = {};

config.paramifiers.start = {
	oninit: function(v) {
		safeMode = v.toLowerCase() == "safe";
	}
};

config.paramifiers.open = {
	onstart: function(v) {
		if(!readOnly || store.tiddlerExists(v) || store.isShadowTiddler(v))
			story.displayTiddler("bottom",v,null,false,null);
	}
};

config.paramifiers.story = {
	onstart: function(v) {
		var list = store.getTiddlerText(v,"").parseParams("open",null,false);
		invokeParamifier(list,"onstart");
	}
};

config.paramifiers.search = {
	onstart: function(v) {
		story.search(v,false,false);
	}
};

config.paramifiers.searchRegExp = {
	onstart: function(v) {
		story.prototype.search(v,false,true);
	}
};

config.paramifiers.tag = {
	onstart: function(v) {
		story.displayTiddlers(null,store.filterTiddlers("[tag["+v+"]]"),null,false,null);
	}
};

config.paramifiers.newTiddler = {
	onstart: function(v) {
		if(!readOnly) {
			story.displayTiddler(null,v,DEFAULT_EDIT_TEMPLATE);
			story.focusTiddler(v,"text");
		}
	}
};

config.paramifiers.newJournal = {
	onstart: function(v) {
		if(!readOnly) {
			var now = new Date();
			var title = now.formatString(v.trim());
			story.displayTiddler(null,title,DEFAULT_EDIT_TEMPLATE);
			story.focusTiddler(title,"text");
		}
	}
};

config.paramifiers.readOnly = {
	onconfig: function(v) {
		var p = v.toLowerCase();
		readOnly = p == "yes" ? true : (p == "no" ? false : readOnly);
	}
};

config.paramifiers.theme = {
	onconfig: function(v) {
		story.switchTheme(v);
	}
};

config.paramifiers.upgrade = {
	onstart: function(v) {
		upgradeFrom(v);
	}
};

config.paramifiers.recent= {
	onstart: function(v) {
		var titles=[];
		var tiddlers=store.getTiddlers("modified","excludeLists").reverse();
		for(var i=0; i<v && i<tiddlers.length; i++)
			titles.push(tiddlers[i].title);
		story.displayTiddlers(null,titles);
	}
};

config.paramifiers.filter = {
	onstart: function(v) {
		story.displayTiddlers(null,store.filterTiddlers(v),null,false);
	}
};

//--
//-- Formatter helpers
//--

function Formatter(formatters)
{
	this.formatters = [];
	var pattern = [];
	for(var n=0; n<formatters.length; n++) {
		pattern.push("(" + formatters[n].match + ")");
		this.formatters.push(formatters[n]);
	}
	this.formatterRegExp = new RegExp(pattern.join("|"),"mg");
}

config.formatterHelpers = {

	createElementAndWikify: function(w)
	{
		w.subWikifyTerm(createTiddlyElement(w.output,this.element),this.termRegExp);
	},

	inlineCssHelper: function(w)
	{
		var styles = [];
		config.textPrimitives.cssLookaheadRegExp.lastIndex = w.nextMatch;
		var lookaheadMatch = config.textPrimitives.cssLookaheadRegExp.exec(w.source);
		while(lookaheadMatch && lookaheadMatch.index == w.nextMatch) {
			var s,v;
			if(lookaheadMatch[1]) {
				s = lookaheadMatch[1].unDash();
				v = lookaheadMatch[2];
			} else {
				s = lookaheadMatch[3].unDash();
				v = lookaheadMatch[4];
			}
			if(s=="bgcolor")
				s = "backgroundColor";
			styles.push({style: s, value: v});
			w.nextMatch = lookaheadMatch.index + lookaheadMatch[0].length;
			config.textPrimitives.cssLookaheadRegExp.lastIndex = w.nextMatch;
			lookaheadMatch = config.textPrimitives.cssLookaheadRegExp.exec(w.source);
		}
		return styles;
	},

	applyCssHelper: function(e,styles)
	{
		for(var t=0; t< styles.length; t++) {
			try {
				e.style[styles[t].style] = styles[t].value;
			} catch (ex) {
			}
		}
	},

	enclosedTextHelper: function(w)
	{
		this.lookaheadRegExp.lastIndex = w.matchStart;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		if(lookaheadMatch && lookaheadMatch.index == w.matchStart) {
			var text = lookaheadMatch[1];
			if(config.browser.isIE)
				text = text.replace(/\n/g,"\r");
			createTiddlyElement(w.output,this.element,null,null,text);
			w.nextMatch = lookaheadMatch.index + lookaheadMatch[0].length;
		}
	},

	isExternalLink: function(link)
	{
		if(store.tiddlerExists(link) || store.isShadowTiddler(link)) {
			return false;
		}
		var urlRegExp = new RegExp(config.textPrimitives.urlPattern,"mg");
		if(urlRegExp.exec(link)) {
			return true;
		}
		if(link.indexOf(".")!=-1 || link.indexOf("\\")!=-1 || link.indexOf("/")!=-1 || link.indexOf("#")!=-1) {
			return true;
		}
		return false;
	}

};

//--
//-- Standard formatters
//--

config.formatters = [
{
	name: "table",
	match: "^\\|(?:[^\\n]*)\\|(?:[fhck]?)$",
	lookaheadRegExp: /^\|([^\n]*)\|([fhck]?)$/mg,
	rowTermRegExp: /(\|(?:[fhck]?)$\n?)/mg,
	cellRegExp: /(?:\|([^\n\|]*)\|)|(\|[fhck]?$\n?)/mg,
	cellTermRegExp: /((?:\x20*)\|)/mg,
	rowTypes: {"c":"caption", "h":"thead", "":"tbody", "f":"tfoot"},
	handler: function(w)
	{
		var table = createTiddlyElement(w.output,"table",null,"twtable");
		var prevColumns = [];
		var currRowType = null;
		var rowContainer;
		var rowCount = 0;
		w.nextMatch = w.matchStart;
		this.lookaheadRegExp.lastIndex = w.nextMatch;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		while(lookaheadMatch && lookaheadMatch.index == w.nextMatch) {
			var nextRowType = lookaheadMatch[2];
			if(nextRowType == "k") {
				table.className = lookaheadMatch[1];
				w.nextMatch += lookaheadMatch[0].length+1;
			} else {
				if(nextRowType != currRowType) {
					rowContainer = createTiddlyElement(table,this.rowTypes[nextRowType]);
					currRowType = nextRowType;
				}
				if(currRowType == "c") {
					// Caption
					w.nextMatch++;
					if(rowContainer != table.firstChild)
						table.insertBefore(rowContainer,table.firstChild);
					rowContainer.setAttribute("align",rowCount == 0?"top":"bottom");
					w.subWikifyTerm(rowContainer,this.rowTermRegExp);
				} else {
					var theRow = createTiddlyElement(rowContainer,"tr",null,(rowCount&1)?"oddRow":"evenRow");
					theRow.onmouseover = function() {addClass(this,"hoverRow");};
					theRow.onmouseout = function() {removeClass(this,"hoverRow");};
					this.rowHandler(w,theRow,prevColumns);
					rowCount++;
				}
			}
			this.lookaheadRegExp.lastIndex = w.nextMatch;
			lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		}
	},
	rowHandler: function(w,e,prevColumns)
	{
		var col = 0;
		var colSpanCount = 1;
		var prevCell = null;
		this.cellRegExp.lastIndex = w.nextMatch;
		var cellMatch = this.cellRegExp.exec(w.source);
		while(cellMatch && cellMatch.index == w.nextMatch) {
			if(cellMatch[1] == "~") {
				// Rowspan
				var last = prevColumns[col];
				if(last) {
					last.rowSpanCount++;
					last.element.setAttribute("rowspan",last.rowSpanCount);
					last.element.setAttribute("rowSpan",last.rowSpanCount); // Needed for IE
					last.element.valign = "center";
				}
				w.nextMatch = this.cellRegExp.lastIndex-1;
			} else if(cellMatch[1] == ">") {
				// Colspan
				colSpanCount++;
				w.nextMatch = this.cellRegExp.lastIndex-1;
			} else if(cellMatch[2]) {
				// End of row
				if(prevCell && colSpanCount > 1) {
					prevCell.setAttribute("colspan",colSpanCount);
					prevCell.setAttribute("colSpan",colSpanCount); // Needed for IE
				}
				w.nextMatch = this.cellRegExp.lastIndex;
				break;
			} else {
				// Cell
				w.nextMatch++;
				var styles = config.formatterHelpers.inlineCssHelper(w);
				var spaceLeft = false;
				var chr = w.source.substr(w.nextMatch,1);
				while(chr == " ") {
					spaceLeft = true;
					w.nextMatch++;
					chr = w.source.substr(w.nextMatch,1);
				}
				var cell;
				if(chr == "!") {
					cell = createTiddlyElement(e,"th");
					w.nextMatch++;
				} else {
					cell = createTiddlyElement(e,"td");
				}
				prevCell = cell;
				prevColumns[col] = {rowSpanCount:1,element:cell};
				if(colSpanCount > 1) {
					cell.setAttribute("colspan",colSpanCount);
					cell.setAttribute("colSpan",colSpanCount); // Needed for IE
					colSpanCount = 1;
				}
				config.formatterHelpers.applyCssHelper(cell,styles);
				w.subWikifyTerm(cell,this.cellTermRegExp);
				if(w.matchText.substr(w.matchText.length-2,1) == " ") // spaceRight
					cell.align = spaceLeft ? "center" : "left";
				else if(spaceLeft)
					cell.align = "right";
				w.nextMatch--;
			}
			col++;
			this.cellRegExp.lastIndex = w.nextMatch;
			cellMatch = this.cellRegExp.exec(w.source);
		}
	}
},

{
	name: "heading",
	match: "^!{1,6}",
	termRegExp: /(\n)/mg,
	handler: function(w)
	{
		w.subWikifyTerm(createTiddlyElement(w.output,"h" + w.matchLength),this.termRegExp);
	}
},

{
	name: "list",
	match: "^(?:[\\*#;:]+)",
	lookaheadRegExp: /^(?:(?:(\*)|(#)|(;)|(:))+)/mg,
	termRegExp: /(\n)/mg,
	handler: function(w)
	{
		var stack = [w.output];
		var currLevel = 0, currType = null;
		var listLevel, listType, itemType, baseType;
		w.nextMatch = w.matchStart;
		this.lookaheadRegExp.lastIndex = w.nextMatch;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		while(lookaheadMatch && lookaheadMatch.index == w.nextMatch) {
			if(lookaheadMatch[1]) {
				listType = "ul";
				itemType = "li";
			} else if(lookaheadMatch[2]) {
				listType = "ol";
				itemType = "li";
			} else if(lookaheadMatch[3]) {
				listType = "dl";
				itemType = "dt";
			} else if(lookaheadMatch[4]) {
				listType = "dl";
				itemType = "dd";
			}
			if(!baseType)
				baseType = listType;
			listLevel = lookaheadMatch[0].length;
			w.nextMatch += lookaheadMatch[0].length;
			var t;
			if(listLevel > currLevel) {
				for(t=currLevel; t<listLevel; t++) {
					var target = (currLevel == 0) ? stack[stack.length-1] : stack[stack.length-1].lastChild;
					stack.push(createTiddlyElement(target,listType));
				}
			} else if(listType!=baseType && listLevel==1) {
				w.nextMatch -= lookaheadMatch[0].length;
				return;
			} else if(listLevel < currLevel) {
				for(t=currLevel; t>listLevel; t--)
					stack.pop();
			} else if(listLevel == currLevel && listType != currType) {
				stack.pop();
				stack.push(createTiddlyElement(stack[stack.length-1].lastChild,listType));
			}
			currLevel = listLevel;
			currType = listType;
			var e = createTiddlyElement(stack[stack.length-1],itemType);
			w.subWikifyTerm(e,this.termRegExp);
			this.lookaheadRegExp.lastIndex = w.nextMatch;
			lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		}
	}
},

{
	name: "quoteByBlock",
	match: "^<<<\\n",
	termRegExp: /(^<<<(\n|$))/mg,
	element: "blockquote",
	handler: config.formatterHelpers.createElementAndWikify
},

{
	name: "quoteByLine",
	match: "^>+",
	lookaheadRegExp: /^>+/mg,
	termRegExp: /(\n)/mg,
	element: "blockquote",
	handler: function(w)
	{
		var stack = [w.output];
		var currLevel = 0;
		var newLevel = w.matchLength;
		var t;
		do {
			if(newLevel > currLevel) {
				for(t=currLevel; t<newLevel; t++)
					stack.push(createTiddlyElement(stack[stack.length-1],this.element));
			} else if(newLevel < currLevel) {
				for(t=currLevel; t>newLevel; t--)
					stack.pop();
			}
			currLevel = newLevel;
			w.subWikifyTerm(stack[stack.length-1],this.termRegExp);
			createTiddlyElement(stack[stack.length-1],"br");
			this.lookaheadRegExp.lastIndex = w.nextMatch;
			var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
			var matched = lookaheadMatch && lookaheadMatch.index == w.nextMatch;
			if(matched) {
				newLevel = lookaheadMatch[0].length;
				w.nextMatch += lookaheadMatch[0].length;
			}
		} while(matched);
	}
},

{
	name: "rule",
	match: "^----+$\\n?",
	handler: function(w)
	{
		createTiddlyElement(w.output,"hr");
	}
},

{
	name: "monospacedByLine",
	match: "^(?:/\\*\\{\\{\\{\\*/|\\{\\{\\{|//\\{\\{\\{|<!--\\{\\{\\{-->)\\n",
	element: "pre",
	handler: function(w)
	{
		switch(w.matchText) {
		case "/*{{{*/\n": // CSS
			this.lookaheadRegExp = /\/\*\{\{\{\*\/\n*((?:^[^\n]*\n)+?)(\n*^\/\*\}\}\}\*\/$\n?)/mg;
			break;
		case "{{{\n": // monospaced block
			this.lookaheadRegExp = /^\{\{\{\n((?:^[^\n]*\n)+?)(^\}\}\}$\n?)/mg;
			break;
		case "//{{{\n": // plugin
			this.lookaheadRegExp = /^\/\/\{\{\{\n\n*((?:^[^\n]*\n)+?)(\n*^\/\/\}\}\}$\n?)/mg;
			break;
		case "<!--{{{-->\n": //template
			this.lookaheadRegExp = /<!--\{\{\{-->\n*((?:^[^\n]*\n)+?)(\n*^<!--\}\}\}-->$\n?)/mg;
			break;
		default:
			break;
		}
		config.formatterHelpers.enclosedTextHelper.call(this,w);
	}
},

{
	name: "wikifyComment",
	match: "^(?:/\\*\\*\\*|<!---)\\n",
	handler: function(w)
	{
		var termRegExp = (w.matchText == "/***\n") ? (/(^\*\*\*\/\n)/mg) : (/(^--->\n)/mg);
		w.subWikifyTerm(w.output,termRegExp);
	}
},

{
	name: "macro",
	match: "<<",
	lookaheadRegExp: /<<([^>\s]+)(?:\s*)((?:[^>]|(?:>(?!>)))*)>>/mg,
	handler: function(w)
	{
		this.lookaheadRegExp.lastIndex = w.matchStart;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		if(lookaheadMatch && lookaheadMatch.index == w.matchStart && lookaheadMatch[1]) {
			w.nextMatch = this.lookaheadRegExp.lastIndex;
			invokeMacro(w.output,lookaheadMatch[1],lookaheadMatch[2],w,w.tiddler);
		}
	}
},

{
	name: "prettyLink",
	match: "\\[\\[",
	lookaheadRegExp: /\[\[(.*?)(?:\|(~)?(.*?))?\]\]/mg,
	handler: function(w)
	{
		this.lookaheadRegExp.lastIndex = w.matchStart;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		if(lookaheadMatch && lookaheadMatch.index == w.matchStart) {
			var e;
			var text = lookaheadMatch[1];
			if(lookaheadMatch[3]) {
				// Pretty bracketted link
				var link = lookaheadMatch[3];
				e = (!lookaheadMatch[2] && config.formatterHelpers.isExternalLink(link)) ?
						createExternalLink(w.output,link) : createTiddlyLink(w.output,decodeURIComponent(link),false,null,w.isStatic,w.tiddler);
			} else {
				// Simple bracketted link
				e = createTiddlyLink(w.output,decodeURIComponent(text),false,null,w.isStatic,w.tiddler);
			}
			createTiddlyText(e,text);
			w.nextMatch = this.lookaheadRegExp.lastIndex;
		}
	}
},

{
	name: "wikiLink",
	match: config.textPrimitives.unWikiLink+"?"+config.textPrimitives.wikiLink,
	handler: function(w)
	{
		if(w.matchText.substr(0,1) == config.textPrimitives.unWikiLink) {
			w.outputText(w.output,w.matchStart+1,w.nextMatch);
			return;
		}
		if(w.matchStart > 0) {
			var preRegExp = new RegExp(config.textPrimitives.anyLetterStrict,"mg");
			preRegExp.lastIndex = w.matchStart-1;
			var preMatch = preRegExp.exec(w.source);
			if(preMatch.index == w.matchStart-1) {
				w.outputText(w.output,w.matchStart,w.nextMatch);
				return;
			}
		}
		if(w.autoLinkWikiWords || store.isShadowTiddler(w.matchText)) {
			var link = createTiddlyLink(w.output,w.matchText,false,null,w.isStatic,w.tiddler);
			w.outputText(link,w.matchStart,w.nextMatch);
		} else {
			w.outputText(w.output,w.matchStart,w.nextMatch);
		}
	}
},

{
	name: "urlLink",
	match: config.textPrimitives.urlPattern,
	handler: function(w)
	{
		w.outputText(createExternalLink(w.output,w.matchText),w.matchStart,w.nextMatch);
	}
},

{
	name: "image",
	match: "\\[[<>]?[Ii][Mm][Gg]\\[",
	lookaheadRegExp: /\[([<]?)(>?)[Ii][Mm][Gg]\[(?:([^\|\]]+)\|)?([^\[\]\|]+)\](?:\[([^\]]*)\])?\]/mg,
	handler: function(w)
	{
		this.lookaheadRegExp.lastIndex = w.matchStart;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		if(lookaheadMatch && lookaheadMatch.index == w.matchStart) {
			var e = w.output;
			if(lookaheadMatch[5]) {
				var link = lookaheadMatch[5];
				e = config.formatterHelpers.isExternalLink(link) ? createExternalLink(w.output,link) : createTiddlyLink(w.output,link,false,null,w.isStatic,w.tiddler);
				addClass(e,"imageLink");
			}
			var img = createTiddlyElement(e,"img");
			if(lookaheadMatch[1])
				img.align = "left";
			else if(lookaheadMatch[2])
				img.align = "right";
			if(lookaheadMatch[3]) {
				img.title = lookaheadMatch[3];
				img.setAttribute("alt",lookaheadMatch[3]);
			}
			img.src = lookaheadMatch[4];
			w.nextMatch = this.lookaheadRegExp.lastIndex;
		}
	}
},

{
	name: "html",
	match: "<[Hh][Tt][Mm][Ll]>",
	lookaheadRegExp: /<[Hh][Tt][Mm][Ll]>((?:.|\n)*?)<\/[Hh][Tt][Mm][Ll]>/mg,
	handler: function(w)
	{
		this.lookaheadRegExp.lastIndex = w.matchStart;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		if(lookaheadMatch && lookaheadMatch.index == w.matchStart) {
			createTiddlyElement(w.output,"span").innerHTML = lookaheadMatch[1];
			w.nextMatch = this.lookaheadRegExp.lastIndex;
		}
	}
},

{
	name: "commentByBlock",
	match: "/%",
	lookaheadRegExp: /\/%((?:.|\n)*?)%\//mg,
	handler: function(w)
	{
		this.lookaheadRegExp.lastIndex = w.matchStart;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		if(lookaheadMatch && lookaheadMatch.index == w.matchStart)
			w.nextMatch = this.lookaheadRegExp.lastIndex;
	}
},

{
	name: "characterFormat",
	match: "''|//|__|\\^\\^|~~|--(?!\\s|$)|\\{\\{\\{",
	handler: function(w)
	{
		switch(w.matchText) {
		case "''":
			w.subWikifyTerm(w.output.appendChild(document.createElement("strong")),/('')/mg);
			break;
		case "//":
			w.subWikifyTerm(createTiddlyElement(w.output,"em"),/(\/\/)/mg);
			break;
		case "__":
			w.subWikifyTerm(createTiddlyElement(w.output,"u"),/(__)/mg);
			break;
		case "^^":
			w.subWikifyTerm(createTiddlyElement(w.output,"sup"),/(\^\^)/mg);
			break;
		case "~~":
			w.subWikifyTerm(createTiddlyElement(w.output,"sub"),/(~~)/mg);
			break;
		case "--":
			w.subWikifyTerm(createTiddlyElement(w.output,"strike"),/(--)/mg);
			break;
		case "{{{":
			var lookaheadRegExp = /\{\{\{((?:.|\n)*?)\}\}\}/mg;
			lookaheadRegExp.lastIndex = w.matchStart;
			var lookaheadMatch = lookaheadRegExp.exec(w.source);
			if(lookaheadMatch && lookaheadMatch.index == w.matchStart) {
				createTiddlyElement(w.output,"code",null,null,lookaheadMatch[1]);
				w.nextMatch = lookaheadRegExp.lastIndex;
			}
			break;
		}
	}
},

{
	name: "customFormat",
	match: "@@|\\{\\{",
	handler: function(w)
	{
		switch(w.matchText) {
		case "@@":
			var e = createTiddlyElement(w.output,"span");
			var styles = config.formatterHelpers.inlineCssHelper(w);
			if(styles.length == 0)
				e.className = "marked";
			else
				config.formatterHelpers.applyCssHelper(e,styles);
			w.subWikifyTerm(e,/(@@)/mg);
			break;
		case "{{":
			var lookaheadRegExp = /\{\{[\s]*([\w]+[\s\w]*)[\s]*\{(\n?)/mg;
			lookaheadRegExp.lastIndex = w.matchStart;
			var lookaheadMatch = lookaheadRegExp.exec(w.source);
			if(lookaheadMatch) {
				w.nextMatch = lookaheadRegExp.lastIndex;
				e = createTiddlyElement(w.output,lookaheadMatch[2] == "\n" ? "div" : "span",null,lookaheadMatch[1]);
				w.subWikifyTerm(e,/(\}\}\})/mg);
			}
			break;
		}
	}
},

{
	name: "mdash",
	match: "--",
	handler: function(w)
	{
		createTiddlyElement(w.output,"span").innerHTML = "&mdash;";
	}
},

{
	name: "lineBreak",
	match: "\\n|<br ?/?>",
	handler: function(w)
	{
		createTiddlyElement(w.output,"br");
	}
},

{
	name: "rawText",
	match: "\\\"{3}|<nowiki>",
	lookaheadRegExp: /(?:\"{3}|<nowiki>)((?:.|\n)*?)(?:\"{3}|<\/nowiki>)/mg,
	handler: function(w)
	{
		this.lookaheadRegExp.lastIndex = w.matchStart;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		if(lookaheadMatch && lookaheadMatch.index == w.matchStart) {
			createTiddlyElement(w.output,"span",null,null,lookaheadMatch[1]);
			w.nextMatch = this.lookaheadRegExp.lastIndex;
		}
	}
},

{
	name: "htmlEntitiesEncoding",
	match: "(?:(?:&#?[a-zA-Z0-9]{2,8};|.)(?:&#?(?:x0*(?:3[0-6][0-9a-fA-F]|1D[c-fC-F][0-9a-fA-F]|20[d-fD-F][0-9a-fA-F]|FE2[0-9a-fA-F])|0*(?:76[89]|7[7-9][0-9]|8[0-7][0-9]|761[6-9]|76[2-7][0-9]|84[0-3][0-9]|844[0-7]|6505[6-9]|6506[0-9]|6507[0-1]));)+|&#?[a-zA-Z0-9]{2,8};)",
	handler: function(w)
	{
		createTiddlyElement(w.output,"span").innerHTML = w.matchText;
	}
}

];

//--
//-- Wikifier
//--

function getParser(tiddler,format)
{
	if(tiddler) {
		if(!format)
			format = tiddler.fields["wikiformat"];
		var i;
		if(format) {
			for(i in config.parsers) {
				if(format == config.parsers[i].format)
					return config.parsers[i];
			}
		} else {
			for(i in config.parsers) {
				if(tiddler.isTagged(config.parsers[i].formatTag))
					return config.parsers[i];
			}
		}
	}
	return formatter;
}

function wikify(source,output,highlightRegExp,tiddler)
{
	if(source) {
		var wikifier = new Wikifier(source,getParser(tiddler),highlightRegExp,tiddler);
		var t0 = new Date();
		wikifier.subWikify(output);
		if(tiddler && config.options.chkDisplayInstrumentation)
			displayMessage("wikify:" +tiddler.title+ " in " + (new Date()-t0) + " ms");
	}
}

function wikifyStatic(source,highlightRegExp,tiddler,format)
{
	var e = createTiddlyElement(document.body,"pre");
	e.style.display = "none";
	var html = "";
	if(source && source != "") {
		if(!tiddler)
			tiddler = new Tiddler("temp");
		var wikifier = new Wikifier(source,getParser(tiddler,format),highlightRegExp,tiddler);
		wikifier.isStatic = true;
		wikifier.subWikify(e);
		html = e.innerHTML;
		removeNode(e);
	}
	return html;
}

function wikifyPlain(title,theStore,limit)
{
	if(!theStore)
		theStore = store;
	if(theStore.tiddlerExists(title) || theStore.isShadowTiddler(title)) {
		return wikifyPlainText(theStore.getTiddlerText(title),limit,tiddler);
	} else {
		return "";
	}
}

function wikifyPlainText(text,limit,tiddler)
{
	if(limit > 0)
		text = text.substr(0,limit);
	var wikifier = new Wikifier(text,formatter,null,tiddler);
	return wikifier.wikifyPlain();
}

function highlightify(source,output,highlightRegExp,tiddler)
{
	if(source) {
		var wikifier = new Wikifier(source,formatter,highlightRegExp,tiddler);
		wikifier.outputText(output,0,source.length);
	}
}

function Wikifier(source,formatter,highlightRegExp,tiddler)
{
	this.source = source;
	this.output = null;
	this.formatter = formatter;
	this.nextMatch = 0;
	this.autoLinkWikiWords = tiddler && tiddler.autoLinkWikiWords() == false ? false : true;
	this.highlightRegExp = highlightRegExp;
	this.highlightMatch = null;
	this.isStatic = false;
	if(highlightRegExp) {
		highlightRegExp.lastIndex = 0;
		this.highlightMatch = highlightRegExp.exec(source);
	}
	this.tiddler = tiddler;
}

Wikifier.prototype.wikifyPlain = function()
{
	var e = createTiddlyElement(document.body,"div");
	e.style.display = "none";
	this.subWikify(e);
	var text = getPlainText(e);
	removeNode(e);
	return text;
};

Wikifier.prototype.subWikify = function(output,terminator)
{
	try {
		if(terminator)
			this.subWikifyTerm(output,new RegExp("(" + terminator + ")","mg"));
		else
			this.subWikifyUnterm(output);
	} catch(ex) {
		showException(ex);
	}
};

Wikifier.prototype.subWikifyUnterm = function(output)
{
	var oldOutput = this.output;
	this.output = output;
	this.formatter.formatterRegExp.lastIndex = this.nextMatch;
	var formatterMatch = this.formatter.formatterRegExp.exec(this.source);
	while(formatterMatch) {
		// Output any text before the match
		if(formatterMatch.index > this.nextMatch)
			this.outputText(this.output,this.nextMatch,formatterMatch.index);
		// Set the match parameters for the handler
		this.matchStart = formatterMatch.index;
		this.matchLength = formatterMatch[0].length;
		this.matchText = formatterMatch[0];
		this.nextMatch = this.formatter.formatterRegExp.lastIndex;
		for(var t=1; t<formatterMatch.length; t++) {
			if(formatterMatch[t]) {
				this.formatter.formatters[t-1].handler(this);
				this.formatter.formatterRegExp.lastIndex = this.nextMatch;
				break;
			}
		}
		formatterMatch = this.formatter.formatterRegExp.exec(this.source);
	}
	if(this.nextMatch < this.source.length) {
		this.outputText(this.output,this.nextMatch,this.source.length);
		this.nextMatch = this.source.length;
	}
	this.output = oldOutput;
};

Wikifier.prototype.subWikifyTerm = function(output,terminatorRegExp)
{
	var oldOutput = this.output;
	this.output = output;
	terminatorRegExp.lastIndex = this.nextMatch;
	var terminatorMatch = terminatorRegExp.exec(this.source);
	this.formatter.formatterRegExp.lastIndex = this.nextMatch;
	var formatterMatch = this.formatter.formatterRegExp.exec(terminatorMatch ? this.source.substr(0,terminatorMatch.index) : this.source);
	while(terminatorMatch || formatterMatch) {
		if(terminatorMatch && (!formatterMatch || terminatorMatch.index <= formatterMatch.index)) {
			if(terminatorMatch.index > this.nextMatch)
				this.outputText(this.output,this.nextMatch,terminatorMatch.index);
			this.matchText = terminatorMatch[1];
			this.matchLength = terminatorMatch[1].length;
			this.matchStart = terminatorMatch.index;
			this.nextMatch = this.matchStart + this.matchLength;
			this.output = oldOutput;
			return;
		}
		if(formatterMatch.index > this.nextMatch)
			this.outputText(this.output,this.nextMatch,formatterMatch.index);
		this.matchStart = formatterMatch.index;
		this.matchLength = formatterMatch[0].length;
		this.matchText = formatterMatch[0];
		this.nextMatch = this.formatter.formatterRegExp.lastIndex;
		for(var t=1; t<formatterMatch.length; t++) {
			if(formatterMatch[t]) {
				this.formatter.formatters[t-1].handler(this);
				this.formatter.formatterRegExp.lastIndex = this.nextMatch;
				break;
			}
		}
		terminatorRegExp.lastIndex = this.nextMatch;
		terminatorMatch = terminatorRegExp.exec(this.source);
		formatterMatch = this.formatter.formatterRegExp.exec(terminatorMatch ? this.source.substr(0,terminatorMatch.index) : this.source);
	}
	if(this.nextMatch < this.source.length) {
		this.outputText(this.output,this.nextMatch,this.source.length);
		this.nextMatch = this.source.length;
	}
	this.output = oldOutput;
};

Wikifier.prototype.outputText = function(place,startPos,endPos)
{
	while(this.highlightMatch && (this.highlightRegExp.lastIndex > startPos) && (this.highlightMatch.index < endPos) && (startPos < endPos)) {
		if(this.highlightMatch.index > startPos) {
			createTiddlyText(place,this.source.substring(startPos,this.highlightMatch.index));
			startPos = this.highlightMatch.index;
		}
		var highlightEnd = Math.min(this.highlightRegExp.lastIndex,endPos);
		var theHighlight = createTiddlyElement(place,"span",null,"highlight",this.source.substring(startPos,highlightEnd));
		startPos = highlightEnd;
		if(startPos >= this.highlightRegExp.lastIndex)
			this.highlightMatch = this.highlightRegExp.exec(this.source);
	}
	if(startPos < endPos) {
		createTiddlyText(place,this.source.substring(startPos,endPos));
	}
};

//--
//-- Macro definitions
//--

config.macros.today.handler = function(place,macroName,params)
{
	var now = new Date();
	var text = params[0] ? now.formatString(params[0].trim()) : now.toLocaleString();
	createTiddlyElement(place,"span",null,null,text);
};

config.macros.version.handler = function(place)
{
	createTiddlyElement(place,"span",null,null,formatVersion());
};

config.macros.list.handler = function(place,macroName,params)
{
	var type = params[0] || "all";
	var list = document.createElement("ul");
	place.appendChild(list);
	if(this[type].prompt)
		createTiddlyElement(list,"li",null,"listTitle",this[type].prompt);
	var results;
	if(this[type].handler)
		results = this[type].handler(params);
	for(var t = 0; t < results.length; t++) {
		var li = document.createElement("li");
		list.appendChild(li);
		createTiddlyLink(li,typeof results[t] == "string" ? results[t] : results[t].title,true);
	}
};

config.macros.list.all.handler = function(params)
{
	return store.reverseLookup("tags","excludeLists",false,"title");
};

config.macros.list.missing.handler = function(params)
{
	return store.getMissingLinks();
};

config.macros.list.orphans.handler = function(params)
{
	return store.getOrphans();
};

config.macros.list.shadowed.handler = function(params)
{
	return store.getShadowed();
};

config.macros.list.touched.handler = function(params)
{
	return store.getTouched();
};

config.macros.list.filter.handler = function(params)
{
	var filter = params[1];
	var results = [];
	if(filter) {
		var tiddlers = store.filterTiddlers(filter);
		for(var t=0; t<tiddlers.length; t++)
			results.push(tiddlers[t].title);
	}
	return results;
};

config.macros.allTags.handler = function(place,macroName,params)
{
	var tags = store.getTags(params[0]);
	var ul = createTiddlyElement(place,"ul");
	if(tags.length == 0)
		createTiddlyElement(ul,"li",null,"listTitle",this.noTags);
	for(var t=0; t<tags.length; t++) {
		var title = tags[t][0];
		var info = getTiddlyLinkInfo(title);
		var li = createTiddlyElement(ul,"li");
		var btn = createTiddlyButton(li,title + " (" + tags[t][1] + ")",this.tooltip.format([title]),onClickTag,info.classes);
		btn.setAttribute("tag",title);
		btn.setAttribute("refresh","link");
		btn.setAttribute("tiddlyLink",title);
	}
};

config.macros.timeline.handler = function(place,macroName,params)
{
	var field = params[0] || "modified";
	var tiddlers = store.reverseLookup("tags","excludeLists",false,field);
	var lastDay = "";
	var last = params[1] ? tiddlers.length-Math.min(tiddlers.length,parseInt(params[1])) : 0;
	var dateFormat = params[2] || this.dateFormat;
	for(var t=tiddlers.length-1; t>=last; t--) {
		var tiddler = tiddlers[t];
		var theDay = tiddler[field].convertToLocalYYYYMMDDHHMM().substr(0,8);
		if(theDay != lastDay) {
			var ul = document.createElement("ul");
			place.appendChild(ul);
			createTiddlyElement(ul,"li",null,"listTitle",tiddler[field].formatString(dateFormat));
			lastDay = theDay;
		}
		createTiddlyElement(ul,"li",null,"listLink").appendChild(createTiddlyLink(place,tiddler.title,true));
	}
};

config.macros.tiddler.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	params = paramString.parseParams("name",null,true,false,true);
	var names = params[0]["name"];
	var tiddlerName = names[0];
	var className = names[1] || null;
	var args = params[0]["with"];
	var wrapper = createTiddlyElement(place,"span",null,className);
	if(!args) {
		wrapper.setAttribute("refresh","content");
		wrapper.setAttribute("tiddler",tiddlerName);
	}
	var text = store.getTiddlerText(tiddlerName);
	if(text) {
		var stack = config.macros.tiddler.tiddlerStack;
		if(stack.indexOf(tiddlerName) !== -1)
			return;
		stack.push(tiddlerName);
		try {
			var n = args ? Math.min(args.length,9) : 0;
			for(var i=0; i<n; i++) {
				var placeholderRE = new RegExp("\\$" + (i + 1),"mg");
				text = text.replace(placeholderRE,args[i]);
			}
			config.macros.tiddler.renderText(wrapper,text,tiddlerName,params);
		} finally {
			stack.pop();
		}
	}
};

config.macros.tiddler.renderText = function(place,text,tiddlerName,params)
{
	wikify(text,place,null,store.getTiddler(tiddlerName));
};

config.macros.tiddler.tiddlerStack = [];

config.macros.tag.handler = function(place,macroName,params)
{
	createTagButton(place,params[0],null,params[1],params[2]);
};

config.macros.tags.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	params = paramString.parseParams("anon",null,true,false,false);
	var ul = createTiddlyElement(place,"ul");
	var title = getParam(params,"anon","");
	if(title && store.tiddlerExists(title))
		tiddler = store.getTiddler(title);
	var sep = getParam(params,"sep"," ");
	var lingo = config.views.wikified.tag;
	var prompt = tiddler.tags.length == 0 ? lingo.labelNoTags : lingo.labelTags;
	createTiddlyElement(ul,"li",null,"listTitle",prompt.format([tiddler.title]));
	for(var t=0; t<tiddler.tags.length; t++) {
		createTagButton(createTiddlyElement(ul,"li"),tiddler.tags[t],tiddler.title);
		if(t<tiddler.tags.length-1)
			createTiddlyText(ul,sep);
	}
};

config.macros.tagging.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	params = paramString.parseParams("anon",null,true,false,false);
	var ul = createTiddlyElement(place,"ul");
	var title = getParam(params,"anon","");
	if(title == "" && tiddler instanceof Tiddler)
		title = tiddler.title;
	var sep = getParam(params,"sep"," ");
	ul.setAttribute("title",this.tooltip.format([title]));
	var tagged = store.getTaggedTiddlers(title);
	var prompt = tagged.length == 0 ? this.labelNotTag : this.label;
	createTiddlyElement(ul,"li",null,"listTitle",prompt.format([title,tagged.length]));
	for(var t=0; t<tagged.length; t++) {
		createTiddlyLink(createTiddlyElement(ul,"li"),tagged[t].title,true);
		if(t<tagged.length-1)
			createTiddlyText(ul,sep);
	}
};

config.macros.closeAll.handler = function(place)
{
	createTiddlyButton(place,this.label,this.prompt,this.onClick);
};

config.macros.closeAll.onClick = function(e)
{
	story.closeAllTiddlers();
	return false;
};

config.macros.permaview.handler = function(place)
{
	createTiddlyButton(place,this.label,this.prompt,this.onClick);
};

config.macros.permaview.onClick = function(e)
{
	story.permaView();
	return false;
};

config.macros.saveChanges.handler = function(place,macroName,params)
{
	if(!readOnly)
		createTiddlyButton(place,params[0] || this.label,params[1] || this.prompt,this.onClick,null,null,this.accessKey);
};

config.macros.saveChanges.onClick = function(e)
{
	saveChanges();
	return false;
};

config.macros.slider.onClickSlider = function(ev)
{
	var e = ev || window.event;
	var n = this.nextSibling;
	var cookie = n.getAttribute("cookie");
	var isOpen = n.style.display != "none";
	if(config.options.chkAnimate && anim && typeof Slider == "function")
		anim.startAnimating(new Slider(n,!isOpen,null,"none"));
	else
		n.style.display = isOpen ? "none" : "block";
	config.options[cookie] = !isOpen;
	saveOptionCookie(cookie);
	return false;
};

config.macros.slider.createSlider = function(place,cookie,title,tooltip)
{
	var c = cookie || "";
	var btn = createTiddlyButton(place,title,tooltip,this.onClickSlider);
	var panel = createTiddlyElement(null,"div",null,"sliderPanel");
	panel.setAttribute("cookie",c);
	panel.style.display = config.options[c] ? "block" : "none";
	place.appendChild(panel);
	return panel;
};

config.macros.slider.handler = function(place,macroName,params)
{
	var panel = this.createSlider(place,params[0],params[2],params[3]);
	var text = store.getTiddlerText(params[1]);
	panel.setAttribute("refresh","content");
	panel.setAttribute("tiddler",params[1]);
	if(text)
		wikify(text,panel,null,store.getTiddler(params[1]));
};

// <<gradient [[tiddler name]] vert|horiz rgb rgb rgb rgb... >>
config.macros.gradient.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	var panel = wikifier ? createTiddlyElement(place,"div",null,"gradient") : place;
	panel.style.position = "relative";
	panel.style.overflow = "hidden";
	panel.style.zIndex = "0";
	if(wikifier) {
		var styles = config.formatterHelpers.inlineCssHelper(wikifier);
		config.formatterHelpers.applyCssHelper(panel,styles);
	}
	params = paramString.parseParams("color");
	var locolors = [], hicolors = [];
	for(var t=2; t<params.length; t++) {
		var c = new RGB(params[t].value);
		if(params[t].name == "snap") {
			hicolors[hicolors.length-1] = c;
		} else {
			locolors.push(c);
			hicolors.push(c);
		}
	}
	drawGradient(panel,params[1].value != "vert",locolors,hicolors);
	if(wikifier)
		wikifier.subWikify(panel,">>");
	if(document.all) {
		panel.style.height = "100%";
		panel.style.width = "100%";
	}
};

config.macros.message.handler = function(place,macroName,params)
{
	if(params[0]) {
		var names = params[0].split(".");
		var lookupMessage = function(root,nameIndex) {
				if(names[nameIndex] in root) {
					if(nameIndex < names.length-1)
						return (lookupMessage(root[names[nameIndex]],nameIndex+1));
					else
						return root[names[nameIndex]];
				} else
					return null;
			};
		var m = lookupMessage(config,0);
		if(m == null)
			m = lookupMessage(window,0);
		createTiddlyText(place,m.toString().format(params.splice(1)));
	}
};


config.macros.view.views = {
	text: function(value,place,params,wikifier,paramString,tiddler) {
		highlightify(value,place,highlightHack,tiddler);
	},
	link: function(value,place,params,wikifier,paramString,tiddler) {
		createTiddlyLink(place,value,true);
	},
	wikified: function(value,place,params,wikifier,paramString,tiddler) {
		if(params[2])
			value=params[2].unescapeLineBreaks().format([value]);
		wikify(value,place,highlightHack,tiddler);
	},
	date: function(value,place,params,wikifier,paramString,tiddler) {
		value = Date.convertFromYYYYMMDDHHMM(value);
		createTiddlyText(place,value.formatString(params[2] ? params[2] : config.views.wikified.dateFormat));
	}
};

config.macros.view.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	if((tiddler instanceof Tiddler) && params[0]) {
		var value = store.getValue(tiddler,params[0]);
		if(value) {
			var type = params[1] || config.macros.view.defaultView;
			var handler = config.macros.view.views[type];
			if(handler)
				handler(value,place,params,wikifier,paramString,tiddler);
		}
	}
};

config.macros.edit.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	var field = params[0];
	var rows = params[1] || 0;
	var defVal = params[2] || '';
	if((tiddler instanceof Tiddler) && field) {
		story.setDirty(tiddler.title,true);
		var e,v;
		if(field != "text" && !rows) {
			e = createTiddlyElement(null,"input");
			if(tiddler.isReadOnly())
				e.setAttribute("readOnly","readOnly");
			e.setAttribute("edit",field);
			e.setAttribute("type","text");
			e.value = store.getValue(tiddler,field) || defVal;
			e.setAttribute("size","40");
			e.setAttribute("autocomplete","off");
			place.appendChild(e);
		} else {
			var wrapper1 = createTiddlyElement(null,"fieldset",null,"fieldsetFix");
			var wrapper2 = createTiddlyElement(wrapper1,"div");
			e = createTiddlyElement(wrapper2,"textarea");
			if(tiddler.isReadOnly())
				e.setAttribute("readOnly","readOnly");
			e.value = v = store.getValue(tiddler,field) || defVal;
			rows = rows || 10;
			var lines = v.match(/\n/mg);
			var maxLines = Math.max(parseInt(config.options.txtMaxEditRows),5);
			if(lines != null && lines.length > rows)
				rows = lines.length + 5;
			rows = Math.min(rows,maxLines);
			e.setAttribute("rows",rows);
			e.setAttribute("edit",field);
			place.appendChild(wrapper1);
		}
		return e;
	}
};

config.macros.tagChooser.onClick = function(ev)
{
	var e = ev || window.event;
	var lingo = config.views.editor.tagChooser;
	var popup = Popup.create(this);
	var tags = store.getTags("excludeLists");
	if(tags.length == 0)
		createTiddlyText(createTiddlyElement(popup,"li"),lingo.popupNone);
	for(var t=0; t<tags.length; t++) {
		var tag = createTiddlyButton(createTiddlyElement(popup,"li"),tags[t][0],lingo.tagTooltip.format([tags[t][0]]),config.macros.tagChooser.onTagClick);
		tag.setAttribute("tag",tags[t][0]);
		tag.setAttribute("tiddler",this.getAttribute("tiddler"));
	}
	Popup.show();
	e.cancelBubble = true;
	if(e.stopPropagation) e.stopPropagation();
	return false;
};

config.macros.tagChooser.onTagClick = function(ev)
{
	var e = ev || window.event;
	if(e.metaKey || e.ctrlKey) stopEvent(e); //# keep popup open on CTRL-click
	var tag = this.getAttribute("tag");
	var title = this.getAttribute("tiddler");
	if(!readOnly)
		story.setTiddlerTag(title,tag,0);
	return false;
};

config.macros.tagChooser.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	if(tiddler instanceof Tiddler) {
		var lingo = config.views.editor.tagChooser;
		var btn = createTiddlyButton(place,lingo.text,lingo.tooltip,this.onClick);
		btn.setAttribute("tiddler",tiddler.title);
	}
};

config.macros.refreshDisplay.handler = function(place)
{
	createTiddlyButton(place,this.label,this.prompt,this.onClick);
};

config.macros.refreshDisplay.onClick = function(e)
{
	refreshAll();
	return false;
};

config.macros.annotations.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	var title = tiddler ? tiddler.title : null;
	var a = title ? config.annotations[title] : null;
	if(!tiddler || !title || !a)
		return;
	var text = a.format([title]);
	wikify(text,createTiddlyElement(place,"div",null,"annotation"),null,tiddler);
};

//--
//-- NewTiddler and NewJournal macros
//--

config.macros.newTiddler.createNewTiddlerButton = function(place,title,params,label,prompt,accessKey,newFocus,isJournal)
{
	var tags = [];
	for(var t=1; t<params.length; t++) {
		if((params[t].name == "anon" && t != 1) || (params[t].name == "tag"))
			tags.push(params[t].value);
	}
	label = getParam(params,"label",label);
	prompt = getParam(params,"prompt",prompt);
	accessKey = getParam(params,"accessKey",accessKey);
	newFocus = getParam(params,"focus",newFocus);
	var customFields = getParam(params,"fields","");
	if(!customFields && !store.isShadowTiddler(title))
		customFields = String.encodeHashMap(config.defaultCustomFields);
	var btn = createTiddlyButton(place,label,prompt,this.onClickNewTiddler,null,null,accessKey);
	btn.setAttribute("newTitle",title);
	btn.setAttribute("isJournal",isJournal ? "true" : "false");
	if(tags.length > 0)
		btn.setAttribute("params",tags.join("|"));
	btn.setAttribute("newFocus",newFocus);
	btn.setAttribute("newTemplate",getParam(params,"template",DEFAULT_EDIT_TEMPLATE));
	if(customFields !== "")
		btn.setAttribute("customFields",customFields);
	var text = getParam(params,"text");
	if(text !== undefined)
		btn.setAttribute("newText",text);
	return btn;
};

config.macros.newTiddler.onClickNewTiddler = function()
{
	var title = this.getAttribute("newTitle");
	if(this.getAttribute("isJournal") == "true") {
		title = new Date().formatString(title.trim());
	}
	var params = this.getAttribute("params");
	var tags = params ? params.split("|") : [];
	var focus = this.getAttribute("newFocus");
	var template = this.getAttribute("newTemplate");
	var customFields = this.getAttribute("customFields");
	if(!customFields && !store.isShadowTiddler(title))
		customFields = String.encodeHashMap(config.defaultCustomFields);
	story.displayTiddler(null,title,template,false,null,null);
	var tiddlerElem = story.getTiddler(title);
	if(customFields)
		story.addCustomFields(tiddlerElem,customFields);
	var text = this.getAttribute("newText");
	if(typeof text == "string")
		story.getTiddlerField(title,"text").value = text.format([title]);
	for(var t=0;t<tags.length;t++)
		story.setTiddlerTag(title,tags[t],+1);
	story.focusTiddler(title,focus);
	return false;
};

config.macros.newTiddler.handler = function(place,macroName,params,wikifier,paramString)
{
	if(!readOnly) {
		params = paramString.parseParams("anon",null,true,false,false);
		var title = params[1] && params[1].name == "anon" ? params[1].value : this.title;
		title = getParam(params,"title",title);
		this.createNewTiddlerButton(place,title,params,this.label,this.prompt,this.accessKey,"title",false);
	}
};

config.macros.newJournal.handler = function(place,macroName,params,wikifier,paramString)
{
	if(!readOnly) {
		params = paramString.parseParams("anon",null,true,false,false);
		var title = params[1] && params[1].name == "anon" ? params[1].value : config.macros.timeline.dateFormat;
		title = getParam(params,"title",title);
		config.macros.newTiddler.createNewTiddlerButton(place,title,params,this.label,this.prompt,this.accessKey,"text",true);
	}
};

//--
//-- Search macro
//--

config.macros.search.handler = function(place,macroName,params)
{
	var searchTimeout = null;
	var btn = createTiddlyButton(place,this.label,this.prompt,this.onClick,"searchButton");
	var txt = createTiddlyElement(place,"input",null,"txtOptionInput searchField");
	if(params[0])
		txt.value = params[0];
	txt.onkeyup = this.onKeyPress;
	txt.onfocus = this.onFocus;
	txt.setAttribute("size",this.sizeTextbox);
	txt.setAttribute("accessKey",this.accessKey);
	txt.setAttribute("autocomplete","off");
	txt.setAttribute("lastSearchText","");
	if(config.browser.isSafari) {
		txt.setAttribute("type","search");
		txt.setAttribute("results","5");
	} else {
		txt.setAttribute("type","text");
	}
};

// Global because there's only ever one outstanding incremental search timer
config.macros.search.timeout = null;

config.macros.search.doSearch = function(txt)
{
	if(txt.value.length > 0) {
		story.search(txt.value,config.options.chkCaseSensitiveSearch,config.options.chkRegExpSearch);
		txt.setAttribute("lastSearchText",txt.value);
	}
};

config.macros.search.onClick = function(e)
{
	config.macros.search.doSearch(this.nextSibling);
	return false;
};

config.macros.search.onKeyPress = function(ev)
{
	var e = ev || window.event;
	switch(e.keyCode) {
		case 13: // Ctrl-Enter
		case 10: // Ctrl-Enter on IE PC
			config.macros.search.doSearch(this);
			break;
		case 27: // Escape
			this.value = "";
			clearMessage();
			break;
	}
	if(config.options.chkIncrementalSearch) {
		if(this.value.length > 2) {
			if(this.value != this.getAttribute("lastSearchText")) {
				if(config.macros.search.timeout)
					clearTimeout(config.macros.search.timeout);
				var txt = this;
				config.macros.search.timeout = setTimeout(function() {config.macros.search.doSearch(txt);},500);
			}
		} else {
			if(config.macros.search.timeout)
				clearTimeout(config.macros.search.timeout);
		}
	}
};

config.macros.search.onFocus = function(e)
{
	this.select();
};

//--
//-- Tabs macro
//--

config.macros.tabs.handler = function(place,macroName,params)
{
	var cookie = params[0];
	var numTabs = (params.length-1)/3;
	var wrapper = createTiddlyElement(null,"div",null,"tabsetWrapper " + cookie);
	var tabset = createTiddlyElement(wrapper,"div",null,"tabset");
	tabset.setAttribute("cookie",cookie);
	var validTab = false;
	for(var t=0; t<numTabs; t++) {
		var label = params[t*3+1];
		var prompt = params[t*3+2];
		var content = params[t*3+3];
		var tab = createTiddlyButton(tabset,label,prompt,this.onClickTab,"tab tabUnselected");
		tab.setAttribute("tab",label);
		tab.setAttribute("content",content);
		tab.title = prompt;
		if(config.options[cookie] == label)
			validTab = true;
	}
	if(!validTab)
		config.options[cookie] = params[1];
	place.appendChild(wrapper);
	this.switchTab(tabset,config.options[cookie]);
};

config.macros.tabs.onClickTab = function(e)
{
	config.macros.tabs.switchTab(this.parentNode,this.getAttribute("tab"));
	return false;
};

config.macros.tabs.switchTab = function(tabset,tab)
{
	var cookie = tabset.getAttribute("cookie");
	var theTab = null;
	var nodes = tabset.childNodes;
	for(var t=0; t<nodes.length; t++) {
		if(nodes[t].getAttribute && nodes[t].getAttribute("tab") == tab) {
			theTab = nodes[t];
			theTab.className = "tab tabSelected";
		} else {
			nodes[t].className = "tab tabUnselected";
		}
	}
	if(theTab) {
		if(tabset.nextSibling && tabset.nextSibling.className == "tabContents")
			removeNode(tabset.nextSibling);
		var tabContent = createTiddlyElement(null,"div",null,"tabContents");
		tabset.parentNode.insertBefore(tabContent,tabset.nextSibling);
		var contentTitle = theTab.getAttribute("content");
		wikify(store.getTiddlerText(contentTitle),tabContent,null,store.getTiddler(contentTitle));
		if(cookie) {
			config.options[cookie] = tab;
			saveOptionCookie(cookie);
		}
	}
};

//--
//-- Tiddler toolbar
//--

// Create a toolbar command button
config.macros.toolbar.createCommand = function(place,commandName,tiddler,className)
{
	if(typeof commandName != "string") {
		var c = null;
		for(var t in config.commands) {
			if(config.commands[t] == commandName)
				c = t;
		}
		commandName = c;
	}
	if((tiddler instanceof Tiddler) && (typeof commandName == "string")) {
		var command = config.commands[commandName];
		if(command.isEnabled ? command.isEnabled(tiddler) : this.isCommandEnabled(command,tiddler)) {
			var text = command.getText ? command.getText(tiddler) : this.getCommandText(command,tiddler);
			var tooltip = command.getTooltip ? command.getTooltip(tiddler) : this.getCommandTooltip(command,tiddler);
			var cmd;
			switch(command.type) {
			case "popup":
				cmd = this.onClickPopup;
				break;
			case "command":
			default:
				cmd = this.onClickCommand;
				break;
			}
			var btn = createTiddlyButton(null,text,tooltip,cmd);
			btn.setAttribute("commandName",commandName);
			btn.setAttribute("tiddler",tiddler.title);
			if(className)
				addClass(btn,className);
			place.appendChild(btn);
		}
	}
};

config.macros.toolbar.isCommandEnabled = function(command,tiddler)
{
	var title = tiddler.title;
	var ro = tiddler.isReadOnly();
	var shadow = store.isShadowTiddler(title) && !store.tiddlerExists(title);
	return (!ro || (ro && !command.hideReadOnly)) && !(shadow && command.hideShadow);
};

config.macros.toolbar.getCommandText = function(command,tiddler)
{
	return tiddler.isReadOnly() && command.readOnlyText || command.text;
};

config.macros.toolbar.getCommandTooltip = function(command,tiddler)
{
	return tiddler.isReadOnly() && command.readOnlyTooltip || command.tooltip;
};

config.macros.toolbar.onClickCommand = function(ev)
{
	var e = ev || window.event;
	e.cancelBubble = true;
	if(e.stopPropagation) e.stopPropagation();
	var command = config.commands[this.getAttribute("commandName")];
	return command.handler(e,this,this.getAttribute("tiddler"));
};

config.macros.toolbar.onClickPopup = function(ev)
{
	var e = ev || window.event;
	e.cancelBubble = true;
	if(e.stopPropagation) e.stopPropagation();
	var popup = Popup.create(this);
	var command = config.commands[this.getAttribute("commandName")];
	var title = this.getAttribute("tiddler");
	var tiddler = store.fetchTiddler(title);
	popup.setAttribute("tiddler",title);
	command.handlePopup(popup,title);
	Popup.show();
	return false;
};

// Invoke the first command encountered from a given place that is tagged with a specified class
config.macros.toolbar.invokeCommand = function(place,className,event)
{
	var children = place.getElementsByTagName("a");
	for(var t=0; t<children.length; t++) {
		var c = children[t];
		if(hasClass(c,className) && c.getAttribute && c.getAttribute("commandName")) {
			if(c.onclick instanceof Function)
				c.onclick.call(c,event);
			break;
		}
	}
};

config.macros.toolbar.onClickMore = function(ev)
{
	var e = this.nextSibling;
	e.style.display = "inline";
	removeNode(this);
	return false;
};

config.macros.toolbar.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	for(var t=0; t<params.length; t++) {
		var c = params[t];
		switch(c) {
		case '>':
			var btn = createTiddlyButton(place,this.moreLabel,this.morePrompt,config.macros.toolbar.onClickMore);
			addClass(btn,"moreCommand");
			var e = createTiddlyElement(place,"span",null,"moreCommand");
			e.style.display = "none";
			place = e;
			break;
		default:
			var className = "";
			switch(c.substr(0,1)) {
			case "+":
				className = "defaultCommand";
				c = c.substr(1);
				break;
			case "-":
				className = "cancelCommand";
				c = c.substr(1);
				break;
			}
			if(c in config.commands)
				this.createCommand(place,c,tiddler,className);
			break;
		}
	}
};

//--
//-- Menu and toolbar commands
//--

config.commands.closeTiddler.handler = function(event,src,title)
{
	if(story.isDirty(title) && !readOnly) {
		if(!confirm(config.commands.cancelTiddler.warning.format([title])))
			return false;
	}
	story.setDirty(title,false);
	story.closeTiddler(title,true);
	return false;
};

config.commands.closeOthers.handler = function(event,src,title)
{
	story.closeAllTiddlers(title);
	return false;
};

config.commands.editTiddler.handler = function(event,src,title)
{
	clearMessage();
	var tiddlerElem = story.getTiddler(title);
	var fields = tiddlerElem.getAttribute("tiddlyFields");
	story.displayTiddler(null,title,DEFAULT_EDIT_TEMPLATE,false,null,fields);
	story.focusTiddler(title,config.options.txtEditorFocus||"text");
	return false;
};

config.commands.saveTiddler.handler = function(event,src,title)
{
	var newTitle = story.saveTiddler(title,event.shiftKey);
	if(newTitle)
		story.displayTiddler(null,newTitle);
	return false;
};

config.commands.cancelTiddler.handler = function(event,src,title)
{
	if(story.hasChanges(title) && !readOnly) {
		if(!confirm(this.warning.format([title])))
			return false;
	}
	story.setDirty(title,false);
	story.displayTiddler(null,title);
	return false;
};

config.commands.deleteTiddler.handler = function(event,src,title)
{
	var deleteIt = true;
	if(config.options.chkConfirmDelete)
		deleteIt = confirm(this.warning.format([title]));
	if(deleteIt) {
		store.removeTiddler(title);
		story.closeTiddler(title,true);
		autoSaveChanges();
	}
	return false;
};

config.commands.permalink.handler = function(event,src,title)
{
	var t = encodeURIComponent(String.encodeTiddlyLink(title));
	if(window.location.hash != t)
		window.location.hash = t;
	return false;
};

config.commands.references.handlePopup = function(popup,title)
{
	var references = store.getReferringTiddlers(title);
	var c = false;
	for(var r=0; r<references.length; r++) {
		if(references[r].title != title && !references[r].isTagged("excludeLists")) {
			createTiddlyLink(createTiddlyElement(popup,"li"),references[r].title,true);
			c = true;
		}
	}
	if(!c)
		createTiddlyText(createTiddlyElement(popup,"li",null,"disabled"),this.popupNone);
};

config.commands.jump.handlePopup = function(popup,title)
{
	story.forEachTiddler(function(title,element) {
		createTiddlyLink(createTiddlyElement(popup,"li"),title,true,null,false,null,true);
		});
};

config.commands.syncing.handlePopup = function(popup,title)
{
	var tiddler = store.fetchTiddler(title);
	if(!tiddler)
		return;
	var serverType = tiddler.getServerType();
	var serverHost = tiddler.fields['server.host'];
	var serverWorkspace = tiddler.fields['server.workspace'];
	if(!serverWorkspace)
		serverWorkspace = "";
	if(serverType) {
		var e = createTiddlyElement(popup,"li",null,"popupMessage");
		e.innerHTML = config.commands.syncing.currentlySyncing.format([serverType,serverHost,serverWorkspace]);
	} else {
		createTiddlyElement(popup,"li",null,"popupMessage",config.commands.syncing.notCurrentlySyncing);
	}
	if(serverType) {
		createTiddlyElement(createTiddlyElement(popup,"li",null,"listBreak"),"div");
		var btn = createTiddlyButton(createTiddlyElement(popup,"li"),this.captionUnSync,null,config.commands.syncing.onChooseServer);
		btn.setAttribute("tiddler",title);
		btn.setAttribute("server.type","");
	}
	createTiddlyElement(createTiddlyElement(popup,"li",null,"listBreak"),"div");
	createTiddlyElement(popup,"li",null,"popupMessage",config.commands.syncing.chooseServer);
	var feeds = store.getTaggedTiddlers("systemServer","title");
	for(var t=0; t<feeds.length; t++) {
		var f = feeds[t];
		var feedServerType = store.getTiddlerSlice(f.title,"Type");
		if(!feedServerType)
			feedServerType = "file";
		var feedServerHost = store.getTiddlerSlice(f.title,"URL");
		if(!feedServerHost)
			feedServerHost = "";
		var feedServerWorkspace = store.getTiddlerSlice(f.title,"Workspace");
		if(!feedServerWorkspace)
			feedServerWorkspace = "";
		var caption = f.title;
		if(serverType == feedServerType && serverHost == feedServerHost && serverWorkspace == feedServerWorkspace) {
			caption = config.commands.syncing.currServerMarker + caption;
		} else {
			caption = config.commands.syncing.notCurrServerMarker + caption;
		}
		btn = createTiddlyButton(createTiddlyElement(popup,"li"),caption,null,config.commands.syncing.onChooseServer);
		btn.setAttribute("tiddler",title);
		btn.setAttribute("server.type",feedServerType);
		btn.setAttribute("server.host",feedServerHost);
		btn.setAttribute("server.workspace",feedServerWorkspace);
	}
};

config.commands.syncing.onChooseServer = function(e)
{
	var tiddler = this.getAttribute("tiddler");
	var serverType = this.getAttribute("server.type");
	if(serverType) {
		store.addTiddlerFields(tiddler,{
			"server.type": serverType,
			"server.host": this.getAttribute("server.host"),
			"server.workspace": this.getAttribute("server.workspace")
			});
	} else {
		store.setValue(tiddler,"server",null);
	}
	return false;
};

config.commands.fields.handlePopup = function(popup,title)
{
	var tiddler = store.fetchTiddler(title);
	if(!tiddler)
		return;
	var fields = {};
	store.forEachField(tiddler,function(tiddler,fieldName,value) {fields[fieldName] = value;},true);
	var items = [];
	for(var t in fields) {
		items.push({field: t,value: fields[t]});
	}
	items.sort(function(a,b) {return a.field < b.field ? -1 : (a.field == b.field ? 0 : +1);});
	if(items.length > 0)
		ListView.create(popup,items,this.listViewTemplate);
	else
		createTiddlyElement(popup,"div",null,null,this.emptyText);
};

//--
//-- Tiddler() object
//--

function Tiddler(title)
{
	this.title = title;
	this.text = "";
	this.modifier = null;
	this.created = new Date();
	this.modified = this.created;
	this.links = [];
	this.linksUpdated = false;
	this.tags = [];
	this.fields = {};
	return this;
}

Tiddler.prototype.getLinks = function()
{
	if(this.linksUpdated==false)
		this.changed();
	return this.links;
};

// Returns the fields that are inherited in string field:"value" field2:"value2" format
Tiddler.prototype.getInheritedFields = function()
{
	var f = {};
	for(var i in this.fields) {
		if(i=="server.host" || i=="server.workspace" || i=="wikiformat"|| i=="server.type") {
			f[i] = this.fields[i];
		}
	}
	return String.encodeHashMap(f);
};

// Increment the changeCount of a tiddler
Tiddler.prototype.incChangeCount = function()
{
	var c = this.fields['changecount'];
	c = c ? parseInt(c,10) : 0;
	this.fields['changecount'] = String(c+1);
};

// Clear the changeCount of a tiddler
Tiddler.prototype.clearChangeCount = function()
{
	if(this.fields['changecount']) {
		delete this.fields['changecount'];
	}
};

Tiddler.prototype.doNotSave = function()
{
	return this.fields['doNotSave'];
};

// Returns true if the tiddler has been updated since the tiddler was created or downloaded
Tiddler.prototype.isTouched = function()
{
	var changeCount = this.fields['changecount'];
	if(changeCount === undefined)
		changeCount = 0;
	return changeCount > 0;
};

// Return the tiddler as an RSS item
Tiddler.prototype.toRssItem = function(uri)
{
	var s = [];
	s.push("<title" + ">" + this.title.htmlEncode() + "</title" + ">");
	s.push("<description>" + wikifyStatic(this.text,null,this).htmlEncode() + "</description>");
	for(var t=0; t<this.tags.length; t++)
		s.push("<category>" + this.tags[t] + "</category>");
	s.push("<link>" + uri + "#" + encodeURIComponent(String.encodeTiddlyLink(this.title)) + "</link>");
	s.push("<pubDate>" + this.modified.toGMTString() + "</pubDate>");
	return s.join("\n");
};

// Format the text for storage in an RSS item
Tiddler.prototype.saveToRss = function(uri)
{
	return "<item>\n" + this.toRssItem(uri) + "\n</item>";
};

// Change the text and other attributes of a tiddler
Tiddler.prototype.set = function(title,text,modifier,modified,tags,created,fields)
{
	this.assign(title,text,modifier,modified,tags,created,fields);
	this.changed();
	return this;
};

// Change the text and other attributes of a tiddler without triggered a tiddler.changed() call
Tiddler.prototype.assign = function(title,text,modifier,modified,tags,created,fields)
{
	if(title != undefined)
		this.title = title;
	if(text != undefined)
		this.text = text;
	if(modifier != undefined)
		this.modifier = modifier;
	if(modified != undefined)
		this.modified = modified;
	if(created != undefined)
		this.created = created;
	if(fields != undefined)
		this.fields = fields;
	if(tags != undefined)
		this.tags = (typeof tags == "string") ? tags.readBracketedList() : tags;
	else if(this.tags == undefined)
		this.tags = [];
	return this;
};

// Get the tags for a tiddler as a string (space delimited, using [[brackets]] for tags containing spaces)
Tiddler.prototype.getTags = function()
{
	return String.encodeTiddlyLinkList(this.tags);
};

// Test if a tiddler carries a tag
Tiddler.prototype.isTagged = function(tag)
{
	return this.tags.indexOf(tag) != -1;
};

// Static method to convert "\n" to newlines, "\s" to "\"
Tiddler.unescapeLineBreaks = function(text)
{
	return text ? text.unescapeLineBreaks() : "";
};

// Convert newlines to "\n", "\" to "\s"
Tiddler.prototype.escapeLineBreaks = function()
{
	return this.text.escapeLineBreaks();
};

// Updates the secondary information (like links[] array) after a change to a tiddler
Tiddler.prototype.changed = function()
{
	this.links = [];
	var t = this.autoLinkWikiWords() ? 0 : 1;
	var tiddlerLinkRegExp = t==0 ? config.textPrimitives.tiddlerAnyLinkRegExp : config.textPrimitives.tiddlerForcedLinkRegExp;
	tiddlerLinkRegExp.lastIndex = 0;
	var formatMatch = tiddlerLinkRegExp.exec(this.text);
	while(formatMatch) {
		var lastIndex = tiddlerLinkRegExp.lastIndex;
		if(t==0 && formatMatch[1] && formatMatch[1] != this.title) {
			// wikiWordLink
			if(formatMatch.index > 0) {
				var preRegExp = new RegExp(config.textPrimitives.unWikiLink+"|"+config.textPrimitives.anyLetter,"mg");
				preRegExp.lastIndex = formatMatch.index-1;
				var preMatch = preRegExp.exec(this.text);
				if(preMatch.index != formatMatch.index-1)
					this.links.pushUnique(formatMatch[1]);
			} else {
				this.links.pushUnique(formatMatch[1]);
			}
		}
		else if(formatMatch[2-t] && !config.formatterHelpers.isExternalLink(formatMatch[3-t])) // titledBrackettedLink
			this.links.pushUnique(formatMatch[3-t]);
		else if(formatMatch[4-t] && formatMatch[4-t] != this.title) // brackettedLink
			this.links.pushUnique(formatMatch[4-t]);
		tiddlerLinkRegExp.lastIndex = lastIndex;
		formatMatch = tiddlerLinkRegExp.exec(this.text);
	}
	this.linksUpdated = true;
};

Tiddler.prototype.getSubtitle = function()
{
	var modifier = this.modifier;
	if(!modifier)
		modifier = config.messages.subtitleUnknown;
	var modified = this.modified;
	if(modified)
		modified = modified.toLocaleString();
	else
		modified = config.messages.subtitleUnknown;
	return config.messages.tiddlerLinkTooltip.format([this.title,modifier,modified]);
};

Tiddler.prototype.isReadOnly = function()
{
	return readOnly;
};

Tiddler.prototype.autoLinkWikiWords = function()
{
	return !(this.isTagged("systemConfig") || this.isTagged("excludeMissing"));
};

Tiddler.prototype.generateFingerprint = function()
{
	return "0x" + Crypto.hexSha1Str(this.text);
};

Tiddler.prototype.getServerType = function()
{
	var serverType = null;
	if(this.fields['server.type'])
		serverType = this.fields['server.type'];
	if(!serverType)
		serverType = this.fields['wikiformat'];
	if(serverType && !config.adaptors[serverType])
		serverType = null;
	return serverType;
};

Tiddler.prototype.getAdaptor = function()
{
	var serverType = this.getServerType();
	return serverType ? new config.adaptors[serverType]() : null;
};

//--
//-- TiddlyWiki() object contains Tiddler()s
//--

function TiddlyWiki()
{
	var tiddlers = {}; // Hashmap by name of tiddlers
	this.tiddlersUpdated = false;
	this.namedNotifications = []; // Array of {name:,notify:} of notification functions
	this.notificationLevel = 0;
	this.slices = {}; // map tiddlerName->(map sliceName->sliceValue). Lazy.
	this.clear = function() {
		tiddlers = {};
		this.setDirty(false);
	};
	this.fetchTiddler = function(title) {
		var t = tiddlers[title];
		return t instanceof Tiddler ? t : null;
	};
	this.deleteTiddler = function(title) {
		delete this.slices[title];
		delete tiddlers[title];
	};
	this.addTiddler = function(tiddler) {
		delete this.slices[tiddler.title];
		tiddlers[tiddler.title] = tiddler;
	};
	this.forEachTiddler = function(callback) {
		for(var t in tiddlers) {
			var tiddler = tiddlers[t];
			if(tiddler instanceof Tiddler)
				callback.call(this,t,tiddler);
		}
	};
}

TiddlyWiki.prototype.setDirty = function(dirty)
{
	this.dirty = dirty;
};

TiddlyWiki.prototype.isDirty = function()
{
	return this.dirty;
};

TiddlyWiki.prototype.tiddlerExists = function(title)
{
	var t = this.fetchTiddler(title);
	return t != undefined;
};

TiddlyWiki.prototype.isShadowTiddler = function(title)
{
	return typeof config.shadowTiddlers[title] == "string";
};

TiddlyWiki.prototype.createTiddler = function(title)
{
	var tiddler = this.fetchTiddler(title);
	if(!tiddler) {
		tiddler = new Tiddler(title);
		this.addTiddler(tiddler);
		this.setDirty(true);
	}
	return tiddler;
};

TiddlyWiki.prototype.getTiddler = function(title)
{
	var t = this.fetchTiddler(title);
	if(t != undefined)
		return t;
	else
		return null;
};

TiddlyWiki.prototype.getTiddlerText = function(title,defaultText)
{
	if(!title)
		return defaultText;
	var pos = title.indexOf(config.textPrimitives.sectionSeparator);
	var section = null;
	if(pos != -1) {
		section = title.substr(pos + config.textPrimitives.sectionSeparator.length);
		title = title.substr(0,pos);
	}
	pos = title.indexOf(config.textPrimitives.sliceSeparator);
	if(pos != -1) {
		var slice = this.getTiddlerSlice(title.substr(0,pos),title.substr(pos + config.textPrimitives.sliceSeparator.length));
		if(slice)
			return slice;
	}
	var tiddler = this.fetchTiddler(title);
	if(tiddler) {
		if(!section)
			return tiddler.text;
		var re = new RegExp("(^!{1,6}" + section.escapeRegExp() + "[ \t]*\n)","mg");
		re.lastIndex = 0;
		var match = re.exec(tiddler.text);
		if(match) {
			var t = tiddler.text.substr(match.index+match[1].length);
			var re2 = /^!/mg;
			re2.lastIndex = 0;
			match = re2.exec(t); //# search for the next heading
			if(match)
				t = t.substr(0,match.index-1);//# don't include final \n
			return t;
		}
		return defaultText;
	}
	if(this.isShadowTiddler(title))
		return config.shadowTiddlers[title];
	if(defaultText != undefined)
		return defaultText;
	return null;
};

TiddlyWiki.prototype.getRecursiveTiddlerText = function(title,defaultText,depth)
{
	var bracketRegExp = new RegExp("(?:\\[\\[([^\\]]+)\\]\\])","mg");
	var text = this.getTiddlerText(title,null);
	if(text == null)
		return defaultText;
	var textOut = [];
	var lastPos = 0;
	do {
		var match = bracketRegExp.exec(text);
		if(match) {
			textOut.push(text.substr(lastPos,match.index-lastPos));
			if(match[1]) {
				if(depth <= 0)
					textOut.push(match[1]);
				else
					textOut.push(this.getRecursiveTiddlerText(match[1],"[[" + match[1] + "]]",depth-1));
			}
			lastPos = match.index + match[0].length;
		} else {
			textOut.push(text.substr(lastPos));
		}
	} while(match);
	return textOut.join("");
};

TiddlyWiki.prototype.slicesRE = /(?:^([\'\/]{0,2})~?([\.\w]+)\:\1\s*([^\n]+)\s*$)|(?:^\|([\'\/]{0,2})~?([\.\w]+)\:?\4\|\s*([^\|\n]+)\s*\|$)/gm;

// @internal
TiddlyWiki.prototype.calcAllSlices = function(title)
{
	var slices = {};
	var text = this.getTiddlerText(title,"");
	this.slicesRE.lastIndex = 0;
	var m = this.slicesRE.exec(text);
	while(m) {
		if(m[2])
			slices[m[2]] = m[3];
		else
			slices[m[5]] = m[6];
		m = this.slicesRE.exec(text);
	}
	return slices;
};

// Returns the slice of text of the given name
TiddlyWiki.prototype.getTiddlerSlice = function(title,sliceName)
{
	var slices = this.slices[title];
	if(!slices) {
		slices = this.calcAllSlices(title);
		this.slices[title] = slices;
	}
	return slices[sliceName];
};

// Build an hashmap of the specified named slices of a tiddler
TiddlyWiki.prototype.getTiddlerSlices = function(title,sliceNames)
{
	var r = {};
	for(var t=0; t<sliceNames.length; t++) {
		var slice = this.getTiddlerSlice(title,sliceNames[t]);
		if(slice)
			r[sliceNames[t]] = slice;
	}
	return r;
};

TiddlyWiki.prototype.suspendNotifications = function()
{
	this.notificationLevel--;
};

TiddlyWiki.prototype.resumeNotifications = function()
{
	this.notificationLevel++;
};

// Invoke the notification handlers for a particular tiddler
TiddlyWiki.prototype.notify = function(title,doBlanket)
{
	if(!this.notificationLevel) {
		for(var t=0; t<this.namedNotifications.length; t++) {
			var n = this.namedNotifications[t];
			if((n.name == null && doBlanket) || (n.name == title))
				n.notify(title);
		}
	}
};

// Invoke the notification handlers for all tiddlers
TiddlyWiki.prototype.notifyAll = function()
{
	if(!this.notificationLevel) {
		for(var t=0; t<this.namedNotifications.length; t++) {
			var n = this.namedNotifications[t];
			if(n.name)
				n.notify(n.name);
		}
	}
};

// Add a notification handler to a tiddler
TiddlyWiki.prototype.addNotification = function(title,fn)
{
	for(var i=0; i<this.namedNotifications.length; i++) {
		if((this.namedNotifications[i].name == title) && (this.namedNotifications[i].notify == fn))
			return this;
	}
	this.namedNotifications.push({name: title, notify: fn});
	return this;
};

TiddlyWiki.prototype.removeTiddler = function(title)
{
	var tiddler = this.fetchTiddler(title);
	if(tiddler) {
		this.deleteTiddler(title);
		this.notify(title,true);
		this.setDirty(true);
	}
};

// Reset the sync status of a freshly synced tiddler
TiddlyWiki.prototype.resetTiddler = function(title)
{
	var tiddler = this.fetchTiddler(title);
	if(tiddler) {
		tiddler.clearChangeCount();
		this.notify(title,true);
		this.setDirty(true);
	}
};

TiddlyWiki.prototype.setTiddlerTag = function(title,status,tag)
{
	var tiddler = this.fetchTiddler(title);
	if(tiddler) {
		var t = tiddler.tags.indexOf(tag);
		if(t != -1)
			tiddler.tags.splice(t,1);
		if(status)
			tiddler.tags.push(tag);
		tiddler.changed();
		tiddler.incChangeCount(title);
		this.notify(title,true);
		this.setDirty(true);
	}
};

TiddlyWiki.prototype.addTiddlerFields = function(title,fields)
{
	var tiddler = this.fetchTiddler(title);
	if(!tiddler)
		return;
	merge(tiddler.fields,fields);
	tiddler.changed();
	tiddler.incChangeCount(title);
	this.notify(title,true);
	this.setDirty(true);
};

TiddlyWiki.prototype.saveTiddler = function(title,newTitle,newBody,modifier,modified,tags,fields,clearChangeCount,created)
{
	var tiddler = this.fetchTiddler(title);
	if(tiddler) {
		created = created || tiddler.created; // Preserve created date
		this.deleteTiddler(title);
	} else {
		created = created || modified;
		tiddler = new Tiddler();
	}
	tiddler.set(newTitle,newBody,modifier,modified,tags,created,fields);
	this.addTiddler(tiddler);
	if(clearChangeCount)
		tiddler.clearChangeCount();
	else
		tiddler.incChangeCount();
	if(title != newTitle)
		this.notify(title,true);
	this.notify(newTitle,true);
	this.setDirty(true);
	return tiddler;
};

TiddlyWiki.prototype.incChangeCount = function(title)
{
	var tiddler = this.fetchTiddler(title);
	if(tiddler)
		tiddler.incChangeCount();
};

TiddlyWiki.prototype.getLoader = function()
{
	if(!this.loader)
		this.loader = new TW21Loader();
	return this.loader;
};

TiddlyWiki.prototype.getSaver = function()
{
	if(!this.saver)
		this.saver = new TW21Saver();
	return this.saver;
};

// Return all tiddlers formatted as an HTML string
TiddlyWiki.prototype.allTiddlersAsHtml = function()
{
	return this.getSaver().externalize(store);
};

// Load contents of a TiddlyWiki from an HTML DIV
TiddlyWiki.prototype.loadFromDiv = function(src,idPrefix,noUpdate)
{
	this.idPrefix = idPrefix;
	var storeElem = (typeof src == "string") ? document.getElementById(src) : src;
	if(!storeElem)
		return;
	var tiddlers = this.getLoader().loadTiddlers(this,storeElem.childNodes);
	this.setDirty(false);
	if(!noUpdate) {
		for(var i = 0;i<tiddlers.length; i++)
			tiddlers[i].changed();
	}
};

// Load contents of a TiddlyWiki from a string
// Returns null if there's an error
TiddlyWiki.prototype.importTiddlyWiki = function(text)
{
	var posDiv = locateStoreArea(text);
	if(!posDiv)
		return null;
	var content = "<" + "html><" + "body>" + text.substring(posDiv[0],posDiv[1] + endSaveArea.length) + "<" + "/body><" + "/html>";
	// Create the iframe
	var iframe = document.createElement("iframe");
	iframe.style.display = "none";
	document.body.appendChild(iframe);
	var doc = iframe.document;
	if(iframe.contentDocument)
		doc = iframe.contentDocument; // For NS6
	else if(iframe.contentWindow)
		doc = iframe.contentWindow.document; // For IE5.5 and IE6
	// Put the content in the iframe
	doc.open();
	doc.writeln(content);
	doc.close();
	// Load the content into a TiddlyWiki() object
	var storeArea = doc.getElementById("storeArea");
	this.loadFromDiv(storeArea,"store");
	// Get rid of the iframe
	iframe.parentNode.removeChild(iframe);
	return this;
};

TiddlyWiki.prototype.updateTiddlers = function()
{
	this.tiddlersUpdated = true;
	this.forEachTiddler(function(title,tiddler) {
		tiddler.changed();
	});
};

// Return an array of tiddlers matching a search regular expression
TiddlyWiki.prototype.search = function(searchRegExp,sortField,excludeTag,match)
{
	var candidates = this.reverseLookup("tags",excludeTag,!!match);
	var results = [];
	for(var t=0; t<candidates.length; t++) {
		if((candidates[t].title.search(searchRegExp) != -1) || (candidates[t].text.search(searchRegExp) != -1))
			results.push(candidates[t]);
	}
	if(!sortField)
		sortField = "title";
	results.sort(function(a,b) {return a[sortField] < b[sortField] ? -1 : (a[sortField] == b[sortField] ? 0 : +1);});
	return results;
};

// Returns a list of all tags in use
//   excludeTag - if present, excludes tags that are themselves tagged with excludeTag
// Returns an array of arrays where [tag][0] is the name of the tag and [tag][1] is the number of occurances
TiddlyWiki.prototype.getTags = function(excludeTag)
{
	var results = [];
	this.forEachTiddler(function(title,tiddler) {
		for(var g=0; g<tiddler.tags.length; g++) {
			var tag = tiddler.tags[g];
			var n = true;
			for(var c=0; c<results.length; c++) {
				if(results[c][0] == tag) {
					n = false;
					results[c][1]++;
				}
			}
			if(n && excludeTag) {
				var t = this.fetchTiddler(tag);
				if(t && t.isTagged(excludeTag))
					n = false;
			}
			if(n)
				results.push([tag,1]);
		}
	});
	results.sort(function(a,b) {return a[0].toLowerCase() < b[0].toLowerCase() ? -1 : (a[0].toLowerCase() == b[0].toLowerCase() ? 0 : +1);});
	return results;
};

// Return an array of the tiddlers that are tagged with a given tag
TiddlyWiki.prototype.getTaggedTiddlers = function(tag,sortField)
{
	return this.reverseLookup("tags",tag,true,sortField);
};

// Return an array of the tiddlers that link to a given tiddler
TiddlyWiki.prototype.getReferringTiddlers = function(title,unusedParameter,sortField)
{
	if(!this.tiddlersUpdated)
		this.updateTiddlers();
	return this.reverseLookup("links",title,true,sortField);
};

// Return an array of the tiddlers that do or do not have a specified entry in the specified storage array (ie, "links" or "tags")
// lookupMatch == true to match tiddlers, false to exclude tiddlers
TiddlyWiki.prototype.reverseLookup = function(lookupField,lookupValue,lookupMatch,sortField)
{
	var results = [];
	this.forEachTiddler(function(title,tiddler) {
		var f = !lookupMatch;
		for(var lookup=0; lookup<tiddler[lookupField].length; lookup++) {
			if(tiddler[lookupField][lookup] == lookupValue)
				f = lookupMatch;
		}
		if(f)
			results.push(tiddler);
	});
	if(!sortField)
		sortField = "title";
	results.sort(function(a,b) {return a[sortField] < b[sortField] ? -1 : (a[sortField] == b[sortField] ? 0 : +1);});
	return results;
};

// Return the tiddlers as a sorted array
TiddlyWiki.prototype.getTiddlers = function(field,excludeTag)
{
	var results = [];
	this.forEachTiddler(function(title,tiddler) {
		if(excludeTag == undefined || !tiddler.isTagged(excludeTag))
			results.push(tiddler);
	});
	if(field)
		results.sort(function(a,b) {return a[field] < b[field] ? -1 : (a[field] == b[field] ? 0 : +1);});
	return results;
};

// Return array of names of tiddlers that are referred to but not defined
TiddlyWiki.prototype.getMissingLinks = function(sortField)
{
	if(!this.tiddlersUpdated)
		this.updateTiddlers();
	var results = [];
	this.forEachTiddler(function (title,tiddler) {
		if(tiddler.isTagged("excludeMissing") || tiddler.isTagged("systemConfig"))
			return;
		for(var n=0; n<tiddler.links.length;n++) {
			var link = tiddler.links[n];
			if(this.fetchTiddler(link) == null && !this.isShadowTiddler(link))
				results.pushUnique(link);
		}
	});
	results.sort();
	return results;
};

// Return an array of names of tiddlers that are defined but not referred to
TiddlyWiki.prototype.getOrphans = function()
{
	var results = [];
	this.forEachTiddler(function (title,tiddler) {
		if(this.getReferringTiddlers(title).length == 0 && !tiddler.isTagged("excludeLists"))
			results.push(title);
	});
	results.sort();
	return results;
};

// Return an array of names of all the shadow tiddlers
TiddlyWiki.prototype.getShadowed = function()
{
	var results = [];
	for(var t in config.shadowTiddlers) {
		if(typeof config.shadowTiddlers[t] == "string")
			results.push(t);
	}
	results.sort();
	return results;
};

// Return an array of tiddlers that have been touched since they were downloaded or created
TiddlyWiki.prototype.getTouched = function()
{
	var results = [];
	this.forEachTiddler(function(title,tiddler) {
		if(tiddler.isTouched())
			results.push(tiddler);
		});
	results.sort();
	return results;
};

// Resolves a Tiddler reference or tiddler title into a Tiddler object, or null if it doesn't exist
TiddlyWiki.prototype.resolveTiddler = function(tiddler)
{
	var t = (typeof tiddler == 'string') ? this.getTiddler(tiddler) : tiddler;
	return t instanceof Tiddler ? t : null;
};

// Filter a list of tiddlers
TiddlyWiki.prototype.filterTiddlers = function(filter)
{
	var results = [];
	if(filter) {
		var tiddler;
		var re = /([^\s\[\]]+)|(?:\[([ \w]+)\[([^\]]+)\]\])|(?:\[\[([^\]]+)\]\])/mg;
		var match = re.exec(filter);
		while(match) {
			if(match[1] || match[4]) {
				var title = match[1] || match[4];
				tiddler = this.fetchTiddler(title);
				if(tiddler) {
					results.pushUnique(tiddler);
				} else if(this.isShadowTiddler(title)) {
					tiddler = new Tiddler();
					tiddler.set(title,this.getTiddlerText(title));
					results.pushUnique(tiddler);
				}
			} else if(match[2]) {
				switch(match[2]) {
					case "tag":
						var matched = this.getTaggedTiddlers(match[3]);
						for(var m = 0; m < matched.length; m++)
							results.pushUnique(matched[m]);
						break;
					case "sort":
						results = this.sortTiddlers(results,match[3]);
						break;
				}
			}
			match = re.exec(filter);
		}
	}
	return results;
};

// Sort a list of tiddlers
TiddlyWiki.prototype.sortTiddlers = function(tiddlers,field)
{
	var asc = +1;
	switch(field.substr(0,1)) {
	case "-":
		asc = -1;
		// Note: this fall-through is intentional
		/*jsl:fallthru*/
	case "+":
		field = field.substr(1);
		break;
	}
	if(TiddlyWiki.standardFieldAccess[field])
		tiddlers.sort(function(a,b) {return a[field] < b[field] ? -asc : (a[field] == b[field] ? 0 : asc);});
	else
		tiddlers.sort(function(a,b) {return a.fields[field] < b.fields[field] ? -asc : (a.fields[field] == b.fields[field] ? 0 : +asc);});
	return tiddlers;
};

// Returns true if path is a valid field name (path),
// i.e. a sequence of identifiers, separated by '.'
TiddlyWiki.isValidFieldName = function(name)
{
	var match = /[a-zA-Z_]\w*(\.[a-zA-Z_]\w*)*/.exec(name);
	return match && (match[0] == name);
};

// Throws an exception when name is not a valid field name.
TiddlyWiki.checkFieldName = function(name)
{
	if(!TiddlyWiki.isValidFieldName(name))
		throw config.messages.invalidFieldName.format([name]);
};

function StringFieldAccess(n,readOnly)
{
	this.set = readOnly ?
			function(t,v) {if(v != t[n]) throw config.messages.fieldCannotBeChanged.format([n]);} :
			function(t,v) {if(v != t[n]) {t[n] = v; return true;}};
	this.get = function(t) {return t[n];};
}

function DateFieldAccess(n)
{
	this.set = function(t,v) {
		var d = v instanceof Date ? v : Date.convertFromYYYYMMDDHHMM(v);
		if(d != t[n]) {
			t[n] = d; return true;
		}
	};
	this.get = function(t) {return t[n].convertToYYYYMMDDHHMM();};
}

function LinksFieldAccess(n)
{
	this.set = function(t,v) {
		var s = (typeof v == "string") ? v.readBracketedList() : v;
		if(s.toString() != t[n].toString()) {
			t[n] = s; return true;
		}
	};
	this.get = function(t) {return String.encodeTiddlyLinkList(t[n]);};
}

TiddlyWiki.standardFieldAccess = {
	// The set functions return true when setting the data has changed the value.
	"title":    new StringFieldAccess("title",true),
	// Handle the "tiddler" field name as the title
	"tiddler":  new StringFieldAccess("title",true),
	"text":     new StringFieldAccess("text"),
	"modifier": new StringFieldAccess("modifier"),
	"modified": new DateFieldAccess("modified"),
	"created":  new DateFieldAccess("created"),
	"tags":     new LinksFieldAccess("tags")
};

TiddlyWiki.isStandardField = function(name)
{
	return TiddlyWiki.standardFieldAccess[name] != undefined;
};

// Sets the value of the given field of the tiddler to the value.
// Setting an ExtendedField's value to null or undefined removes the field.
// Setting a namespace to undefined removes all fields of that namespace.
// The fieldName is case-insensitive.
// All values will be converted to a string value.
TiddlyWiki.prototype.setValue = function(tiddler,fieldName,value)
{
	TiddlyWiki.checkFieldName(fieldName);
	var t = this.resolveTiddler(tiddler);
	if(!t)
		return;
	fieldName = fieldName.toLowerCase();
	var isRemove = (value === undefined) || (value === null);
	var accessor = TiddlyWiki.standardFieldAccess[fieldName];
	if(accessor) {
		if(isRemove)
			// don't remove StandardFields
			return;
		var h = TiddlyWiki.standardFieldAccess[fieldName];
		if(!h.set(t,value))
			return;
	} else {
		var oldValue = t.fields[fieldName];
		if(isRemove) {
			if(oldValue !== undefined) {
				// deletes a single field
				delete t.fields[fieldName];
			} else {
				// no concrete value is defined for the fieldName
				// so we guess this is a namespace path.
				// delete all fields in a namespace
				var re = new RegExp('^'+fieldName+'\\.');
				var dirty = false;
				for(var n in t.fields) {
					if(n.match(re)) {
						delete t.fields[n];
						dirty = true;
					}
				}
				if(!dirty)
					return;
			}
		} else {
			// the "normal" set case. value is defined (not null/undefined)
			// For convenience provide a nicer conversion Date->String
			value = value instanceof Date ? value.convertToYYYYMMDDHHMMSSMMM() : String(value);
			if(oldValue == value)
				return;
			t.fields[fieldName] = value;
		}
	}
	// When we are here the tiddler/store really was changed.
	this.notify(t.title,true);
	if(!fieldName.match(/^temp\./))
		this.setDirty(true);
};

// Returns the value of the given field of the tiddler.
// The fieldName is case-insensitive.
// Will only return String values (or undefined).
TiddlyWiki.prototype.getValue = function(tiddler,fieldName)
{
	var t = this.resolveTiddler(tiddler);
	if(!t)
		return undefined;
	fieldName = fieldName.toLowerCase();
	var accessor = TiddlyWiki.standardFieldAccess[fieldName];
	if(accessor) {
		return accessor.get(t);
	}
	return t.fields[fieldName];
};

// Calls the callback function for every field in the tiddler.
// When callback function returns a non-false value the iteration stops
// and that value is returned.
// The order of the fields is not defined.
// @param callback a function(tiddler,fieldName,value).
TiddlyWiki.prototype.forEachField = function(tiddler,callback,onlyExtendedFields)
{
	var t = this.resolveTiddler(tiddler);
	if(!t)
		return undefined;
	var n,result;
	for(n in t.fields) {
		result = callback(t,n,t.fields[n]);
		if(result)
			return result;
		}
	if(onlyExtendedFields)
		return undefined;
	for(n in TiddlyWiki.standardFieldAccess) {
		if(n == "tiddler")
			// even though the "title" field can also be referenced through the name "tiddler"
			// we only visit this field once.
			continue;
		result = callback(t,n,TiddlyWiki.standardFieldAccess[n].get(t));
		if(result)
			return result;
	}
	return undefined;
};

//--
//-- Story functions
//--

function Story(containerId,idPrefix)
{
	this.container = containerId;
	this.idPrefix = idPrefix;
	this.highlightRegExp = null;
	this.tiddlerId = function(title) {
		var id = this.idPrefix + title;
		return id==this.container ? this.idPrefix + "_" + title : id;
	};
	this.containerId = function() {
		return this.container;
	};
}

Story.prototype.getTiddler = function(title)
{
	return document.getElementById(this.tiddlerId(title));
};

Story.prototype.getContainer = function()
{
	return document.getElementById(this.containerId());
};

Story.prototype.forEachTiddler = function(fn)
{
	var place = this.getContainer();
	if(!place)
		return;
	var e = place.firstChild;
	while(e) {
		var n = e.nextSibling;
		var title = e.getAttribute("tiddler");
		fn.call(this,title,e);
		e = n;
	}
};

Story.prototype.displayDefaultTiddlers = function()
{
	this.displayTiddlers(null,store.filterTiddlers(store.getTiddlerText("DefaultTiddlers")));
};

Story.prototype.displayTiddlers = function(srcElement,titles,template,animate,unused,customFields,toggle)
{
	for(var t = titles.length-1;t>=0;t--)
		this.displayTiddler(srcElement,titles[t],template,animate,unused,customFields);
};

Story.prototype.displayTiddler = function(srcElement,tiddler,template,animate,unused,customFields,toggle,animationSrc)
{
	var title = (tiddler instanceof Tiddler) ? tiddler.title : tiddler;
	var tiddlerElem = this.getTiddler(title);
	if(tiddlerElem) {
		if(toggle)
			this.closeTiddler(title,true);
		else
			this.refreshTiddler(title,template,false,customFields);
	} else {
		var place = this.getContainer();
		var before = this.positionTiddler(srcElement);
		tiddlerElem = this.createTiddler(place,before,title,template,customFields);
	}
	if(animationSrc && typeof animationSrc !== "string") {
		srcElement = animationSrc;
	}
	if(srcElement && typeof srcElement !== "string") {
		if(config.options.chkAnimate && (animate == undefined || animate == true) && anim && typeof Zoomer == "function" && typeof Scroller == "function")
			anim.startAnimating(new Zoomer(title,srcElement,tiddlerElem),new Scroller(tiddlerElem));
		else
			window.scrollTo(0,ensureVisible(tiddlerElem));
	}
};

Story.prototype.positionTiddler = function(srcElement)
{
	var place = this.getContainer();
	var before = null;
	if(typeof srcElement == "string") {
		switch(srcElement) {
		case "top":
			before = place.firstChild;
			break;
		case "bottom":
			before = null;
			break;
		}
	} else {
		var after = this.findContainingTiddler(srcElement);
		if(after == null) {
			before = place.firstChild;
		} else if(after.nextSibling) {
			before = after.nextSibling;
			if(before.nodeType != 1)
				before = null;
		}
	}
	return before;
};

Story.prototype.createTiddler = function(place,before,title,template,customFields)
{
	var tiddlerElem = createTiddlyElement(null,"div",this.tiddlerId(title),"tiddler");
	tiddlerElem.setAttribute("refresh","tiddler");
	if(customFields)
		tiddlerElem.setAttribute("tiddlyFields",customFields);
	place.insertBefore(tiddlerElem,before);
	var defaultText = null;
	if(!store.tiddlerExists(title) && !store.isShadowTiddler(title))
		defaultText = this.loadMissingTiddler(title,customFields,tiddlerElem);
	this.refreshTiddler(title,template,false,customFields,defaultText);
	return tiddlerElem;
};

Story.prototype.loadMissingTiddler = function(title,fields,tiddlerElem)
{
	var tiddler = new Tiddler(title);
	tiddler.fields = typeof fields == "string" ? fields.decodeHashMap() : (fields || {});
	var serverType = tiddler.getServerType();
	var host = tiddler.fields['server.host'];
	var workspace = tiddler.fields['server.workspace'];
	if(!serverType || !host)
		return null;
	var sm = new SyncMachine(serverType,{
			start: function() {
				return this.openHost(host,"openWorkspace");
			},
			openWorkspace: function() {
				return this.openWorkspace(workspace,"getTiddler");
			},
			getTiddler: function() {
				return this.getTiddler(title,"onGetTiddler");
			},
			onGetTiddler: function(context) {
				var tiddler = context.tiddler;
				if(tiddler && tiddler.text) {
					var downloaded = new Date();
					if(!tiddler.created)
						tiddler.created = downloaded;
					if(!tiddler.modified)
						tiddler.modified = tiddler.created;
					store.saveTiddler(tiddler.title,tiddler.title,tiddler.text,tiddler.modifier,tiddler.modified,tiddler.tags,tiddler.fields,true,tiddler.created);
					autoSaveChanges();
				}
				delete this;
				return true;
			},
			error: function(message) {
				displayMessage("Error loading missing tiddler from %0: %1".format([host,message]));
			}
		});
	sm.go();
	return config.messages.loadingMissingTiddler.format([title,serverType,host,workspace]);
};

Story.prototype.chooseTemplateForTiddler = function(title,template)
{
	if(!template)
		template = DEFAULT_VIEW_TEMPLATE;
	if(template == DEFAULT_VIEW_TEMPLATE || template == DEFAULT_EDIT_TEMPLATE)
		template = config.tiddlerTemplates[template];
	return template;
};

Story.prototype.getTemplateForTiddler = function(title,template,tiddler)
{
	return store.getRecursiveTiddlerText(template,null,10);
};

Story.prototype.refreshTiddler = function(title,template,force,customFields,defaultText)
{
	var tiddlerElem = this.getTiddler(title);
	if(tiddlerElem) {
		if(tiddlerElem.getAttribute("dirty") == "true" && !force)
			return tiddlerElem;
		template = this.chooseTemplateForTiddler(title,template);
		var currTemplate = tiddlerElem.getAttribute("template");
		if((template != currTemplate) || force) {
			var tiddler = store.getTiddler(title);
			if(!tiddler) {
				tiddler = new Tiddler();
				if(store.isShadowTiddler(title)) {
					tiddler.set(title,store.getTiddlerText(title),config.views.wikified.shadowModifier,version.date,[],version.date);
				} else {
					var text = template=="EditTemplate" ?
								config.views.editor.defaultText.format([title]) :
								config.views.wikified.defaultText.format([title]);
					text = defaultText || text;
					var fields = customFields ? customFields.decodeHashMap() : null;
					tiddler.set(title,text,config.views.wikified.defaultModifier,version.date,[],version.date,fields);
				}
			}
			tiddlerElem.setAttribute("tags",tiddler.tags.join(" "));
			tiddlerElem.setAttribute("tiddler",title);
			tiddlerElem.setAttribute("template",template);
			tiddlerElem.onmouseover = this.onTiddlerMouseOver;
			tiddlerElem.onmouseout = this.onTiddlerMouseOut;
			tiddlerElem.ondblclick = this.onTiddlerDblClick;
			tiddlerElem[window.event?"onkeydown":"onkeypress"] = this.onTiddlerKeyPress;
			tiddlerElem.innerHTML = this.getTemplateForTiddler(title,template,tiddler);
			applyHtmlMacros(tiddlerElem,tiddler);
			if(store.getTaggedTiddlers(title).length > 0)
				addClass(tiddlerElem,"isTag");
			else
				removeClass(tiddlerElem,"isTag");
			if(store.tiddlerExists(title)) {
				removeClass(tiddlerElem,"shadow");
				removeClass(tiddlerElem,"missing");
			} else {
				addClass(tiddlerElem,store.isShadowTiddler(title) ? "shadow" : "missing");
			}
			if(customFields)
				this.addCustomFields(tiddlerElem,customFields);
			forceReflow();
		}
	}
	return tiddlerElem;
};

Story.prototype.addCustomFields = function(place,customFields)
{
	var fields = customFields.decodeHashMap();
	var w = document.createElement("div");
	w.style.display = "none";
	place.appendChild(w);
	for(var t in fields) {
		var e = document.createElement("input");
		e.setAttribute("type","text");
		e.setAttribute("value",fields[t]);
		w.appendChild(e);
		e.setAttribute("edit",t);
	}
};

Story.prototype.refreshAllTiddlers = function(force)
{
	var e = this.getContainer().firstChild;
	while(e) {
		var template = e.getAttribute("template");
		if(template && e.getAttribute("dirty") != "true") {
			this.refreshTiddler(e.getAttribute("tiddler"),force ? null : template,true);
		}
		e = e.nextSibling;
	}
};

Story.prototype.onTiddlerMouseOver = function(e)
{
	if(window.addClass instanceof Function)
		addClass(this,"selected");
};

Story.prototype.onTiddlerMouseOut = function(e)
{
	if(window.removeClass instanceof Function)
		removeClass(this,"selected");
};

Story.prototype.onTiddlerDblClick = function(ev)
{
	var e = ev || window.event;
	var target = resolveTarget(e);
	if(target && target.nodeName.toLowerCase() != "input" && target.nodeName.toLowerCase() != "textarea") {
		if(document.selection && document.selection.empty)
			document.selection.empty();
		config.macros.toolbar.invokeCommand(this,"defaultCommand",e);
		e.cancelBubble = true;
		if(e.stopPropagation) e.stopPropagation();
		return true;
	}
	return false;
};

Story.prototype.onTiddlerKeyPress = function(ev)
{
	var e = ev || window.event;
	clearMessage();
	var consume = false;
	var title = this.getAttribute("tiddler");
	var target = resolveTarget(e);
	switch(e.keyCode) {
	case 9: // Tab
		if(config.options.chkInsertTabs && target.tagName.toLowerCase() == "textarea") {
			replaceSelection(target,String.fromCharCode(9));
			consume = true;
		}
		if(config.isOpera) {
			target.onblur = function() {
				this.focus();
				this.onblur = null;
			};
		}
		break;
	case 13: // Ctrl-Enter
	case 10: // Ctrl-Enter on IE PC
	case 77: // Ctrl-Enter is "M" on some platforms
		if(e.ctrlKey) {
			blurElement(this);
			config.macros.toolbar.invokeCommand(this,"defaultCommand",e);
			consume = true;
		}
		break;
	case 27: // Escape
		blurElement(this);
		config.macros.toolbar.invokeCommand(this,"cancelCommand",e);
		consume = true;
		break;
	}
	e.cancelBubble = consume;
	if(consume) {
		if(e.stopPropagation) e.stopPropagation(); // Stop Propagation
		e.returnValue = true; // Cancel The Event in IE
		if(e.preventDefault ) e.preventDefault(); // Cancel The Event in Moz
	}
	return !consume;
};

Story.prototype.getTiddlerField = function(title,field)
{
	var tiddlerElem = this.getTiddler(title);
	var e = null;
	if(tiddlerElem ) {
		var children = tiddlerElem.getElementsByTagName("*");
		for(var t=0; t<children.length; t++) {
			var c = children[t];
			if(c.tagName.toLowerCase() == "input" || c.tagName.toLowerCase() == "textarea") {
				if(!e)
					e = c;
				if(c.getAttribute("edit") == field)
					e = c;
			}
		}
	}
	return e;
};

Story.prototype.focusTiddler = function(title,field)
{
	var e = this.getTiddlerField(title,field);
	if(e) {
		e.focus();
		e.select();
	}
};

Story.prototype.blurTiddler = function(title)
{
	var tiddlerElem = this.getTiddler(title);
	if(tiddlerElem && tiddlerElem.focus && tiddlerElem.blur) {
		tiddlerElem.focus();
		tiddlerElem.blur();
	}
};

Story.prototype.setTiddlerField = function(title,tag,mode,field)
{
	var c = this.getTiddlerField(title,field);
	var tags = c.value.readBracketedList();
	tags.setItem(tag,mode);
	c.value = String.encodeTiddlyLinkList(tags);
};

Story.prototype.setTiddlerTag = function(title,tag,mode)
{
	this.setTiddlerField(title,tag,mode,"tags");
};

Story.prototype.closeTiddler = function(title,animate,unused)
{
	var tiddlerElem = this.getTiddler(title);
	if(tiddlerElem) {
		clearMessage();
		this.scrubTiddler(tiddlerElem);
		if(config.options.chkAnimate && animate && anim && typeof Slider == "function")
			anim.startAnimating(new Slider(tiddlerElem,false,null,"all"));
		else {
			removeNode(tiddlerElem);
			forceReflow();
		}
	}
};

Story.prototype.scrubTiddler = function(tiddlerElem)
{
	tiddlerElem.id = null;
};

Story.prototype.setDirty = function(title,dirty)
{
	var tiddlerElem = this.getTiddler(title);
	if(tiddlerElem)
		tiddlerElem.setAttribute("dirty",dirty ? "true" : "false");
};

Story.prototype.isDirty = function(title)
{
	var tiddlerElem = this.getTiddler(title);
	if(tiddlerElem)
		return tiddlerElem.getAttribute("dirty") == "true";
	return null;
};

Story.prototype.areAnyDirty = function()
{
	var r = false;
	this.forEachTiddler(function(title,element) {
		if(this.isDirty(title))
			r = true;
	});
	return r;
};

Story.prototype.closeAllTiddlers = function(exclude)
{
	clearMessage();
	this.forEachTiddler(function(title,element) {
		if((title != exclude) && element.getAttribute("dirty") != "true")
			this.closeTiddler(title);
	});
	window.scrollTo(0,ensureVisible(this.container));
};

Story.prototype.isEmpty = function()
{
	var place = this.getContainer();
	return place && place.firstChild == null;
};

Story.prototype.search = function(text,useCaseSensitive,useRegExp)
{
	this.closeAllTiddlers();
	highlightHack = new RegExp(useRegExp ? text : text.escapeRegExp(),useCaseSensitive ? "mg" : "img");
	var matches = store.search(highlightHack,"title","excludeSearch");
	this.displayTiddlers(null,matches);
	highlightHack = null;
	var q = useRegExp ? "/" : "'";
	if(matches.length > 0)
		displayMessage(config.macros.search.successMsg.format([matches.length.toString(),q + text + q]));
	else
		displayMessage(config.macros.search.failureMsg.format([q + text + q]));
};

Story.prototype.findContainingTiddler = function(e)
{
	while(e && !hasClass(e,"tiddler"))
		e = e.parentNode;
	return e;
};

Story.prototype.gatherSaveFields = function(e,fields)
{
	if(e && e.getAttribute) {
		var f = e.getAttribute("edit");
		if(f)
			fields[f] = e.value.replace(/\r/mg,"");
		if(e.hasChildNodes()) {
			var c = e.childNodes;
			for(var t=0; t<c.length; t++)
				this.gatherSaveFields(c[t],fields);
		}
	}
};

Story.prototype.hasChanges = function(title)
{
	var e = this.getTiddler(title);
	if(e) {
		var fields = {};
		this.gatherSaveFields(e,fields);
		var tiddler = store.fetchTiddler(title);
		if(!tiddler)
			return false;
		for(var n in fields) {
			if(store.getValue(title,n) != fields[n])
				return true;
		}
	}
	return false;
};

Story.prototype.saveTiddler = function(title,minorUpdate)
{
	var tiddlerElem = this.getTiddler(title);
	if(tiddlerElem) {
		var fields = {};
		this.gatherSaveFields(tiddlerElem,fields);
		var newTitle = fields.title || title;
		if(!store.tiddlerExists(newTitle))
			newTitle = newTitle.trim();
		if(store.tiddlerExists(newTitle) && newTitle != title) {
			if(!confirm(config.messages.overwriteWarning.format([newTitle.toString()])))
				return null;
		}
		if(newTitle != title)
			this.closeTiddler(newTitle,false);
		tiddlerElem.id = this.tiddlerId(newTitle);
		tiddlerElem.setAttribute("tiddler",newTitle);
		tiddlerElem.setAttribute("template",DEFAULT_VIEW_TEMPLATE);
		tiddlerElem.setAttribute("dirty","false");
		if(config.options.chkForceMinorUpdate)
			minorUpdate = !minorUpdate;
		if(!store.tiddlerExists(newTitle))
			minorUpdate = false;
		var newDate = new Date();
		var extendedFields = store.tiddlerExists(newTitle) ? store.fetchTiddler(newTitle).fields : (newTitle!=title && store.tiddlerExists(title) ? store.fetchTiddler(title).fields : config.defaultCustomFields);
		for(var n in fields) {
			if(!TiddlyWiki.isStandardField(n))
				extendedFields[n] = fields[n];
		}
		var tiddler = store.saveTiddler(title,newTitle,fields.text,minorUpdate ? undefined : config.options.txtUserName,minorUpdate ? undefined : newDate,fields.tags,extendedFields);
		autoSaveChanges(null,[tiddler]);
		return newTitle;
	}
	return null;
};

Story.prototype.permaView = function()
{
	var links = [];
	this.forEachTiddler(function(title,element) {
		links.push(String.encodeTiddlyLink(title));
	});
	var t = encodeURIComponent(links.join(" "));
	if(t == "")
		t = "#";
	if(window.location.hash != t)
		window.location.hash = t;
};

Story.prototype.switchTheme = function(theme)
{
	if(safeMode)
		return;

	var isAvailable = function(title) {
		var s = title ? title.indexOf(config.textPrimitives.sectionSeparator) : -1;
		if(s!=-1)
			title = title.substr(0,s);
		return store.tiddlerExists(title) || store.isShadowTiddler(title);
	};

	var getSlice = function(theme,slice) {
		var r;
		if(readOnly)
			r = store.getTiddlerSlice(theme,slice+"ReadOnly") || store.getTiddlerSlice(theme,"Web"+slice);
		r = r || store.getTiddlerSlice(theme,slice);
		if(r && r.indexOf(config.textPrimitives.sectionSeparator)==0)
			r = theme + r;
		return isAvailable(r) ? r : slice;
	};

	var replaceNotification = function(i,name,theme,slice) {
		var newName = getSlice(theme,slice);
		if(name!=newName && store.namedNotifications[i].name==name) {
			store.namedNotifications[i].name = newName;
			return newName;
		}
		return name;
	};

	var pt = config.refresherData.pageTemplate;
	var vi = DEFAULT_VIEW_TEMPLATE;
	var vt = config.tiddlerTemplates[vi];
	var ei = DEFAULT_EDIT_TEMPLATE;
	var et = config.tiddlerTemplates[ei];

	for(var i=0; i<config.notifyTiddlers.length; i++) {
		var name = config.notifyTiddlers[i].name;
		switch(name) {
		case "PageTemplate":
			config.refresherData.pageTemplate = replaceNotification(i,config.refresherData.pageTemplate,theme,name);
			break;
		case "StyleSheet":
			removeStyleSheet(config.refresherData.styleSheet);
			config.refresherData.styleSheet = replaceNotification(i,config.refresherData.styleSheet,theme,name);
			break;
		case "ColorPalette":
			config.refresherData.colorPalette = replaceNotification(i,config.refresherData.colorPalette,theme,name);
			break;
		default:
			break;
		}
	}
	config.tiddlerTemplates[vi] = getSlice(theme,"ViewTemplate");
	config.tiddlerTemplates[ei] = getSlice(theme,"EditTemplate");
	if(!startingUp) {
		if(config.refresherData.pageTemplate!=pt || config.tiddlerTemplates[vi]!=vt || config.tiddlerTemplates[ei]!=et) {
			refreshAll();
			this.refreshAllTiddlers(true);
		} else {
			setStylesheet(store.getRecursiveTiddlerText(config.refresherData.styleSheet,"",10),config.refreshers.styleSheet);
		}
		config.options.txtTheme = theme;
		saveOptionCookie("txtTheme");
	}
};

//--
//-- Backstage
//--

var backstage = {
	area: null,
	toolbar: null,
	button: null,
	showButton: null,
	hideButton: null,
	cloak: null,
	panel: null,
	panelBody: null,
	panelFooter: null,
	currTabName: null,
	currTabElem: null,
	content: null,

	init: function() {
		var cmb = config.messages.backstage;
		this.area = document.getElementById("backstageArea");
		this.toolbar = document.getElementById("backstageToolbar");
		this.button = document.getElementById("backstageButton");
		this.button.style.display = "block";
		var t = cmb.open.text + " " + glyph("bentArrowLeft");
		this.showButton = createTiddlyButton(this.button,t,cmb.open.tooltip,
						function(e) {backstage.show(); return false;},null,"backstageShow");
		t = glyph("bentArrowRight") + " " + cmb.close.text;
		this.hideButton = createTiddlyButton(this.button,t,cmb.close.tooltip,
						function(e) {backstage.hide(); return false;},null,"backstageHide");
		this.cloak = document.getElementById("backstageCloak");
		this.panel = document.getElementById("backstagePanel");
		this.panelFooter = createTiddlyElement(this.panel,"div",null,"backstagePanelFooter");
		this.panelBody = createTiddlyElement(this.panel,"div",null,"backstagePanelBody");
		this.cloak.onmousedown = function(e) {backstage.switchTab(null);};
		createTiddlyText(this.toolbar,cmb.prompt);
		for(t=0; t<config.backstageTasks.length; t++) {
			var taskName = config.backstageTasks[t];
			var task = config.tasks[taskName];
			var handler = task.action ? this.onClickCommand : this.onClickTab;
			var text = task.text + (task.action ? "" : glyph("downTriangle"));
			var btn = createTiddlyButton(this.toolbar,text,task.tooltip,handler,"backstageTab");
			btn.setAttribute("task",taskName);
			addClass(btn,task.action ? "backstageAction" : "backstageTask");
			}
		this.content = document.getElementById("contentWrapper");
		if(config.options.chkBackstage)
			this.show();
		else
			this.hide();
	},

	isVisible: function() {
		return this.area ? this.area.style.display == "block" : false;
	},

	show: function() {
		this.area.style.display = "block";
		if(anim && config.options.chkAnimate) {
			backstage.toolbar.style.left = findWindowWidth() + "px";
			var p = [{style: "left", start: findWindowWidth(), end: 0, template: "%0px"}];
			anim.startAnimating(new Morpher(backstage.toolbar,config.animDuration,p));
		} else {
			backstage.area.style.left = "0px";
		}
		this.showButton.style.display = "none";
		this.hideButton.style.display = "block";
		config.options.chkBackstage = true;
		saveOptionCookie("chkBackstage");
		addClass(this.content,"backstageVisible");
	},

	hide: function() {
		if(this.currTabElem) {
			this.switchTab(null);
		} else {
			backstage.toolbar.style.left = "0px";
			if(anim && config.options.chkAnimate) {
				var p = [{style: "left", start: 0, end: findWindowWidth(), template: "%0px"}];
				var c = function(element,properties) {backstage.area.style.display = "none";};
				anim.startAnimating(new Morpher(backstage.toolbar,config.animDuration,p,c));
			} else {
				this.area.style.display = "none";
			}
			this.showButton.style.display = "block";
			this.hideButton.style.display = "none";
			config.options.chkBackstage = false;
			saveOptionCookie("chkBackstage");
			removeClass(this.content,"backstageVisible");
		}
	},

	onClickCommand: function(e) {
		var task = config.tasks[this.getAttribute("task")];
		displayMessage(task);
		if(task.action) {
			backstage.switchTab(null);
			task.action();
		}
		return false;
	},

	onClickTab: function(e) {
		backstage.switchTab(this.getAttribute("task"));
		return false;
	},

	// Switch to a given tab, or none if null is passed
	switchTab: function(tabName) {
		var tabElem = null;
		var e = this.toolbar.firstChild;
		while(e)
			{
			if(e.getAttribute && e.getAttribute("task") == tabName)
				tabElem = e;
			e = e.nextSibling;
			}
		if(tabName == backstage.currTabName)
			return;
		if(backstage.currTabElem) {
			removeClass(this.currTabElem,"backstageSelTab");
		}
		if(tabElem && tabName) {
			backstage.preparePanel();
			addClass(tabElem,"backstageSelTab");
			var task = config.tasks[tabName];
			wikify(task.content,backstage.panelBody,null,null);
			backstage.showPanel();
		} else if(backstage.currTabElem) {
			backstage.hidePanel();
		}
		backstage.currTabName = tabName;
		backstage.currTabElem = tabElem;
	},

	isPanelVisible: function() {
		return backstage.panel ? backstage.panel.style.display == "block" : false;
	},

	preparePanel: function() {
		backstage.cloak.style.height = findWindowHeight() + "px";
		backstage.cloak.style.display = "block";
		removeChildren(backstage.panelBody);
		return backstage.panelBody;
	},

	showPanel: function() {
		backstage.panel.style.display = "block";
		if(anim && config.options.chkAnimate) {
			backstage.panel.style.top = (-backstage.panel.offsetHeight) + "px";
			var p = [{style: "top", start: -backstage.panel.offsetHeight, end: 0, template: "%0px"}];
			anim.startAnimating(new Morpher(backstage.panel,config.animDuration,p),new Scroller(backstage.panel,false));
		} else {
			backstage.panel.style.top = "0px";
		}
		return backstage.panelBody;
	},

	hidePanel: function() {
		if(backstage.currTabElem)
			removeClass(backstage.currTabElem,"backstageSelTab");
		backstage.currTabElem = null;
		backstage.currTabName = null;
		if(anim && config.options.chkAnimate) {
			var p = [
				{style: "top", start: 0, end: -(backstage.panel.offsetHeight), template: "%0px"},
				{style: "display", atEnd: "none"}
			];
			var c = function(element,properties) {backstage.cloak.style.display = "none";};
			anim.startAnimating(new Morpher(backstage.panel,config.animDuration,p,c));
		 } else {
			backstage.panel.style.display = "none";
			backstage.cloak.style.display = "none";
		}
	}
};

config.macros.backstage = {};

config.macros.backstage.handler = function(place,macroName,params)
{
	var backstageTask = config.tasks[params[0]];
	if(backstageTask)
		createTiddlyButton(place,backstageTask.text,backstageTask.tooltip,function(e) {backstage.switchTab(params[0]); return false;});
};

//--
//-- ImportTiddlers macro
//--

config.macros.importTiddlers.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	if(readOnly) {
		createTiddlyElement(place,"div",null,"marked",this.readOnlyWarning);
		return;
	}
	var w = new Wizard();
	w.createWizard(place,this.wizardTitle);
	this.restart(w);
};

config.macros.importTiddlers.onCancel = function(e)
{
	var wizard = new Wizard(this);
	var place = wizard.clear();
	config.macros.importTiddlers.restart(wizard);
	return false;
};

config.macros.importTiddlers.onClose = function(e)
{
	backstage.hidePanel();
	return false;
};

config.macros.importTiddlers.restart = function(wizard)
{
	wizard.addStep(this.step1Title,this.step1Html);
	var s = wizard.getElement("selTypes");
	for(var t in config.adaptors) {
		var e = createTiddlyElement(s,"option",null,null,config.adaptors[t].serverLabel ? config.adaptors[t].serverLabel : t);
		e.value = t;
	}
	if(config.defaultAdaptor)
		s.value = config.defaultAdaptor;
	s = wizard.getElement("selFeeds");
	var feeds = this.getFeeds();
	for(t in feeds) {
		e = createTiddlyElement(s,"option",null,null,t);
		e.value = t;
	}
	wizard.setValue("feeds",feeds);
	s.onchange = config.macros.importTiddlers.onFeedChange;
	var fileInput = wizard.getElement("txtBrowse");
	fileInput.onchange = config.macros.importTiddlers.onBrowseChange;
	fileInput.onkeyup = config.macros.importTiddlers.onBrowseChange;
	wizard.setButtons([{caption: this.openLabel, tooltip: this.openPrompt, onClick: config.macros.importTiddlers.onOpen}]);
	wizard.formElem.action = "javascript:;";
	wizard.formElem.onsubmit = function() {
		if(this.txtPath.value.length)
			this.lastChild.firstChild.onclick();
	};
};

config.macros.importTiddlers.getFeeds = function()
{
	var feeds = {};
	var tagged = store.getTaggedTiddlers("systemServer","title");
	for(var t=0; t<tagged.length; t++) {
		var title = tagged[t].title;
		var serverType = store.getTiddlerSlice(title,"Type");
		if(!serverType)
			serverType = "file";
		feeds[title] = {title: title,
						url: store.getTiddlerSlice(title,"URL"),
						workspace: store.getTiddlerSlice(title,"Workspace"),
						workspaceList: store.getTiddlerSlice(title,"WorkspaceList"),
						tiddlerFilter: store.getTiddlerSlice(title,"TiddlerFilter"),
						serverType: serverType,
						description: store.getTiddlerSlice(title,"Description")};
	}
	return feeds;
};

config.macros.importTiddlers.onFeedChange = function(e)
{
	var wizard = new Wizard(this);
	var selTypes = wizard.getElement("selTypes");
	var fileInput = wizard.getElement("txtPath");
	var feeds = wizard.getValue("feeds");
	var f = feeds[this.value];
	if(f) {
		selTypes.value = f.serverType;
		fileInput.value = f.url;
		wizard.setValue("feedName",f.serverType);
		wizard.setValue("feedHost",f.url);
		wizard.setValue("feedWorkspace",f.workspace);
		wizard.setValue("feedWorkspaceList",f.workspaceList);
		wizard.setValue("feedTiddlerFilter",f.tiddlerFilter);
	}
	return false;
};

config.macros.importTiddlers.onBrowseChange = function(e)
{
	var wizard = new Wizard(this);
	var fileInput = wizard.getElement("txtPath");
	fileInput.value = config.macros.importTiddlers.getURLFromLocalPath(this.value);
	var serverType = wizard.getElement("selTypes");
	serverType.value = "file";
	return true;
};

config.macros.importTiddlers.getURLFromLocalPath = function(v)
{
	if(!v||!v.length)
		return v;
	v = v.replace(/\\/g,"/"); // use "/" for cross-platform consistency
	var u;
	var t = v.split(":");
	var p = t[1]||t[0]; // remove drive letter (if any)
	if (t[1] && (t[0]=="http"||t[0]=="https"||t[0]=="file")) {
		u = v;
	} else if(p.substr(0,1)=="/") {
		u = document.location.protocol + "//" + document.location.hostname + (t[1] ? "/" : "") + v;
	} else {
		var c = document.location.href.replace(/\\/g,"/");
		var pos = c.lastIndexOf("/");
		if (pos!=-1)
			c = c.substr(0,pos); // remove filename
		u = c + "/" + p;
	}
	return u;
};

config.macros.importTiddlers.onOpen = function(e)
{
	var wizard = new Wizard(this);
	var fileInput = wizard.getElement("txtPath");
	var url = fileInput.value;
	var serverType = wizard.getElement("selTypes").value || config.defaultAdaptor;
	var adaptor = new config.adaptors[serverType]();
	wizard.setValue("adaptor",adaptor);
	wizard.setValue("serverType",serverType);
	wizard.setValue("host",url);
	var ret = adaptor.openHost(url,null,wizard,config.macros.importTiddlers.onOpenHost);
	if(ret !== true)
		displayMessage(ret);
	wizard.setButtons([{caption: config.macros.importTiddlers.cancelLabel, tooltip: config.macros.importTiddlers.cancelPrompt, onClick: config.macros.importTiddlers.onCancel}],config.macros.importTiddlers.statusOpenHost);
	return false;
};

config.macros.importTiddlers.onOpenHost = function(context,wizard)
{
	var adaptor = wizard.getValue("adaptor");
	if(context.status !== true)
		displayMessage("Error in importTiddlers.onOpenHost: " + context.statusText);
	var ret = adaptor.getWorkspaceList(context,wizard,config.macros.importTiddlers.onGetWorkspaceList);
	if(ret !== true)
		displayMessage(ret);
	wizard.setButtons([{caption: config.macros.importTiddlers.cancelLabel, tooltip: config.macros.importTiddlers.cancelPrompt, onClick: config.macros.importTiddlers.onCancel}],config.macros.importTiddlers.statusGetWorkspaceList);
};

config.macros.importTiddlers.onGetWorkspaceList = function(context,wizard)
{
	if(context.status !== true)
		displayMessage("Error in importTiddlers.onGetWorkspaceList: " + context.statusText);
	wizard.setValue("context",context);
	var workspace = wizard.getValue("feedWorkspace");
	if(!workspace && context.workspaces.length==1)
		workspace = context.workspaces[0].title;
	if(workspace) {
		var ret = context.adaptor.openWorkspace(workspace,context,wizard,config.macros.importTiddlers.onOpenWorkspace);
		if(ret !== true)
			displayMessage(ret);
		wizard.setValue("workspace",workspace);
		wizard.setButtons([{caption: config.macros.importTiddlers.cancelLabel, tooltip: config.macros.importTiddlers.cancelPrompt, onClick: config.macros.importTiddlers.onCancel}],config.macros.importTiddlers.statusOpenWorkspace);
		return;
	}
	wizard.addStep(config.macros.importTiddlers.step2Title,config.macros.importTiddlers.step2Html);
	var s = wizard.getElement("selWorkspace");
	s.onchange = config.macros.importTiddlers.onWorkspaceChange;
	for(var t=0; t<context.workspaces.length; t++) {
		var e = createTiddlyElement(s,"option",null,null,context.workspaces[t].title);
		e.value = context.workspaces[t].title;
	}
	var workspaceList = wizard.getValue("feedWorkspaceList");
	if(workspaceList) {
		var list = workspaceList.parseParams("workspace",null,false,true);
		for(var n=1; n<list.length; n++) {
			if(context.workspaces.findByField("title",list[n].value) == null) {
				e = createTiddlyElement(s,"option",null,null,list[n].value);
				e.value = list[n].value;
			}
		}
	}
	if(workspace) {
		t = wizard.getElement("txtWorkspace");
		t.value = workspace;
	}
	wizard.setButtons([{caption: config.macros.importTiddlers.openLabel, tooltip: config.macros.importTiddlers.openPrompt, onClick: config.macros.importTiddlers.onChooseWorkspace}]);
};

config.macros.importTiddlers.onWorkspaceChange = function(e)
{
	var wizard = new Wizard(this);
	var t = wizard.getElement("txtWorkspace");
	t.value = this.value;
	this.selectedIndex = 0;
	return false;
};

config.macros.importTiddlers.onChooseWorkspace = function(e)
{
	var wizard = new Wizard(this);
	var adaptor = wizard.getValue("adaptor");
	var workspace = wizard.getElement("txtWorkspace").value;
	wizard.setValue("workspace",workspace);
	var context = wizard.getValue("context");
	var ret = adaptor.openWorkspace(workspace,context,wizard,config.macros.importTiddlers.onOpenWorkspace);
	if(ret !== true)
		displayMessage(ret);
	wizard.setButtons([{caption: config.macros.importTiddlers.cancelLabel, tooltip: config.macros.importTiddlers.cancelPrompt, onClick: config.macros.importTiddlers.onCancel}],config.macros.importTiddlers.statusOpenWorkspace);
	return false;
};

config.macros.importTiddlers.onOpenWorkspace = function(context,wizard)
{
	if(context.status !== true)
		displayMessage("Error in importTiddlers.onOpenWorkspace: " + context.statusText);
	var adaptor = wizard.getValue("adaptor");
	var ret = adaptor.getTiddlerList(context,wizard,config.macros.importTiddlers.onGetTiddlerList,wizard.getValue("feedTiddlerFilter"));
	if(ret !== true)
		displayMessage(ret);
	wizard.setButtons([{caption: config.macros.importTiddlers.cancelLabel, tooltip: config.macros.importTiddlers.cancelPrompt, onClick: config.macros.importTiddlers.onCancel}],config.macros.importTiddlers.statusGetTiddlerList);
};

config.macros.importTiddlers.onGetTiddlerList = function(context,wizard)
{
	if(context.status !== true) {
		wizard.setButtons([{caption: config.macros.importTiddlers.cancelLabel, tooltip: config.macros.importTiddlers.cancelPrompt, onClick: config.macros.importTiddlers.onCancel}],config.macros.importTiddlers.errorGettingTiddlerList);
		return;
	}
	// Extract data for the listview
	var listedTiddlers = [];
	if(context.tiddlers) {
		for(var n=0; n<context.tiddlers.length; n++) {
			var tiddler = context.tiddlers[n];
			listedTiddlers.push({
				title: tiddler.title,
				modified: tiddler.modified,
				modifier: tiddler.modifier,
				text: tiddler.text ? wikifyPlainText(tiddler.text,100) : "",
				tags: tiddler.tags,
				size: tiddler.text ? tiddler.text.length : 0,
				tiddler: tiddler
			});
		}
	}
	listedTiddlers.sort(function(a,b) {return a.title < b.title ? -1 : (a.title == b.title ? 0 : +1);});
	// Display the listview
	wizard.addStep(config.macros.importTiddlers.step3Title,config.macros.importTiddlers.step3Html);
	var markList = wizard.getElement("markList");
	var listWrapper = document.createElement("div");
	markList.parentNode.insertBefore(listWrapper,markList);
	var listView = ListView.create(listWrapper,listedTiddlers,config.macros.importTiddlers.listViewTemplate);
	wizard.setValue("listView",listView);
	var txtSaveTiddler = wizard.getElement("txtSaveTiddler");
	txtSaveTiddler.value = config.macros.importTiddlers.generateSystemServerName(wizard);
	wizard.setButtons([
			{caption: config.macros.importTiddlers.cancelLabel, tooltip: config.macros.importTiddlers.cancelPrompt, onClick: config.macros.importTiddlers.onCancel},
			{caption: config.macros.importTiddlers.importLabel, tooltip: config.macros.importTiddlers.importPrompt, onClick: config.macros.importTiddlers.doImport}
		]);
};

config.macros.importTiddlers.generateSystemServerName = function(wizard)
{
	var serverType = wizard.getValue("serverType");
	var host = wizard.getValue("host");
	var workspace = wizard.getValue("workspace");
	var pattern = config.macros.importTiddlers[workspace ? "systemServerNamePattern" : "systemServerNamePatternNoWorkspace"];
	return pattern.format([serverType,host,workspace]);
};

config.macros.importTiddlers.saveServerTiddler = function(wizard)
{
	var txtSaveTiddler = wizard.getElement("txtSaveTiddler").value;
	if(store.tiddlerExists(txtSaveTiddler)) {
		if(!confirm(config.macros.importTiddlers.confirmOverwriteSaveTiddler.format([txtSaveTiddler])))
			return;
		store.suspendNotifications();
		store.removeTiddler(txtSaveTiddler);
		store.resumeNotifications();
	}
	var serverType = wizard.getValue("serverType");
	var host = wizard.getValue("host");
	var workspace = wizard.getValue("workspace");
	var text = config.macros.importTiddlers.serverSaveTemplate.format([serverType,host,workspace]);
	store.saveTiddler(txtSaveTiddler,txtSaveTiddler,text,config.macros.importTiddlers.serverSaveModifier,new Date(),["systemServer"]);
};

config.macros.importTiddlers.doImport = function(e)
{
	var wizard = new Wizard(this);
	if(wizard.getElement("chkSave").checked)
		config.macros.importTiddlers.saveServerTiddler(wizard);
	var chkSync = wizard.getElement("chkSync").checked;
	wizard.setValue("sync",chkSync);
	var listView = wizard.getValue("listView");
	var rowNames = ListView.getSelectedRows(listView);
	var adaptor = wizard.getValue("adaptor");
	var overwrite = [];
	var t;
	for(t=0; t<rowNames.length; t++) {
		if(store.tiddlerExists(rowNames[t]))
			overwrite.push(rowNames[t]);
	}
	if(overwrite.length > 0) {
		if(!confirm(config.macros.importTiddlers.confirmOverwriteText.format([overwrite.join(", ")])))
			return false;
	}
	wizard.addStep(config.macros.importTiddlers.step4Title.format([rowNames.length]),config.macros.importTiddlers.step4Html);
	for(t=0; t<rowNames.length; t++) {
		var link = document.createElement("div");
		createTiddlyLink(link,rowNames[t],true);
		var place = wizard.getElement("markReport");
		place.parentNode.insertBefore(link,place);
	}
	wizard.setValue("remainingImports",rowNames.length);
	wizard.setButtons([
			{caption: config.macros.importTiddlers.cancelLabel, tooltip: config.macros.importTiddlers.cancelPrompt, onClick: config.macros.importTiddlers.onCancel}
		],config.macros.importTiddlers.statusDoingImport);
	for(t=0; t<rowNames.length; t++) {
		var context = {};
		context.allowSynchronous = true;
		var inbound = adaptor.getTiddler(rowNames[t],context,wizard,config.macros.importTiddlers.onGetTiddler);
	}
	return false;
};

config.macros.importTiddlers.onGetTiddler = function(context,wizard)
{
	if(!context.status)
		displayMessage("Error in importTiddlers.onGetTiddler: " + context.statusText);
	var tiddler = context.tiddler;
	store.suspendNotifications();
	store.saveTiddler(tiddler.title, tiddler.title, tiddler.text, tiddler.modifier, tiddler.modified, tiddler.tags, tiddler.fields, true, tiddler.created);
	if(!wizard.getValue("sync")) {
		store.setValue(tiddler.title,'server',null);
	}
	store.resumeNotifications();
	if(!context.isSynchronous)
		store.notify(tiddler.title,true);
	var remainingImports = wizard.getValue("remainingImports")-1;
	wizard.setValue("remainingImports",remainingImports);
	if(remainingImports == 0) {
		if(context.isSynchronous) {
			store.notifyAll();
			refreshDisplay();
		}
		wizard.setButtons([
				{caption: config.macros.importTiddlers.doneLabel, tooltip: config.macros.importTiddlers.donePrompt, onClick: config.macros.importTiddlers.onClose}
			],config.macros.importTiddlers.statusDoneImport);
		autoSaveChanges();
	}
};

//--
//-- Upgrade macro
//--

config.macros.upgrade.handler = function(place)
{
	var w = new Wizard();
	w.createWizard(place,this.wizardTitle);
	w.addStep(this.step1Title,this.step1Html.format([this.source,this.source]));
	w.setButtons([{caption: this.upgradeLabel, tooltip: this.upgradePrompt, onClick: this.onClickUpgrade}]);
};

config.macros.upgrade.onClickUpgrade = function(e)
{
	var me = config.macros.upgrade;
	var w = new Wizard(this);
	if(window.location.protocol != "file:") {
		alert(me.errorCantUpgrade);
		return false;
	}
	if(story.areAnyDirty() || store.isDirty()) {
		alert(me.errorNotSaved);
		return false;
	}
	var localPath = getLocalPath(document.location.toString());
	var backupPath = getBackupPath(localPath,me.backupExtension);
	w.setValue("backupPath",backupPath);
	w.setButtons([],me.statusPreparingBackup);
	var original = loadOriginal(localPath);
	w.setButtons([],me.statusSavingBackup);
	var backup = config.browser.isIE ? ieCopyFile(backupPath,localPath) : saveFile(backupPath,original);
	if(backup != true) {
		w.setButtons([],me.errorSavingBackup);
		alert(me.errorSavingBackup);
		return false;
	}
	w.setButtons([],me.statusLoadingCore);
	var load = loadRemoteFile(me.source,me.onLoadCore,w);
	if(typeof load == "string") {
		w.setButtons([],me.errorLoadingCore);
		alert(me.errorLoadingCore);
		return false;
	}
	return false;
};

config.macros.upgrade.onLoadCore = function(status,params,responseText,url,xhr)
{
	var me = config.macros.upgrade;
	var w = params;
	var errMsg;
	if(!status)
		errMsg = me.errorLoadingCore;
	var newVer = me.extractVersion(responseText);
	if(!newVer)
		errMsg = me.errorCoreFormat;
	if(errMsg) {
		w.setButtons([],errMsg);
		alert(errMsg);
		return;
	}
	var onStartUpgrade = function(e) {
		w.setButtons([],me.statusSavingCore);
		var localPath = getLocalPath(document.location.toString());
		saveFile(localPath,responseText);
		w.setButtons([],me.statusReloadingCore);
		var backupPath = w.getValue("backupPath");
		var newLoc = document.location.toString() + '?time=' + new Date().convertToYYYYMMDDHHMM() + '#upgrade:[[' + encodeURI(backupPath) + ']]';
		window.setTimeout(function () {window.location = newLoc;},10);
	};
	var step2 = [me.step2Html_downgrade,me.step2Html_restore,me.step2Html_upgrade][compareVersions(version,newVer) + 1];
	w.addStep(me.step2Title,step2.format([formatVersion(newVer),formatVersion(version)]));
	w.setButtons([{caption: me.startLabel, tooltip: me.startPrompt, onClick: onStartUpgrade},{caption: me.cancelLabel, tooltip: me.cancelPrompt, onClick: me.onCancel}]);
};

config.macros.upgrade.onCancel = function(e)
{
	var me = config.macros.upgrade;
	var w = new Wizard(this);
	w.addStep(me.step3Title,me.step3Html);
	w.setButtons([]);
	return false;
};

config.macros.upgrade.extractVersion = function(upgradeFile)
{
	var re = /^var version = \{title: "([^"]+)", major: (\d+), minor: (\d+), revision: (\d+)(, beta: (\d+)){0,1}, date: new Date\("([^"]+)"\)/mg;
	var m = re.exec(upgradeFile);
	return  m ? {title: m[1], major: m[2], minor: m[3], revision: m[4], beta: m[6], date: new Date(m[7])} : null;
};

function upgradeFrom(path)
{
	var importStore = new TiddlyWiki();
	var tw = loadFile(path);
	if(window.netscape !== undefined)
		tw = convertUTF8ToUnicode(tw);
	importStore.importTiddlyWiki(tw);
	importStore.forEachTiddler(function(title,tiddler) {
		if(!store.getTiddler(title)) {
			store.addTiddler(tiddler);
		}
	});
	refreshDisplay();
	saveChanges(); //# To create appropriate Markup* sections
	alert(config.messages.upgradeDone.format([formatVersion()]));
	window.location = window.location.toString().substr(0,window.location.toString().lastIndexOf('?'));
}

//--
//-- Sync macro
//--

// Synchronisation handlers
config.syncers = {};

// Sync state.
var currSync = null;

// sync macro
config.macros.sync.handler = function(place,macroName,params,wikifier,paramString,tiddler)
{
	if(!wikifier.isStatic)
		this.startSync(place);
};

config.macros.sync.cancelSync = function()
{
	currSync = null;
};

config.macros.sync.startSync = function(place)
{
	if(currSync)
		config.macros.sync.cancelSync();
	currSync = {};
	currSync.syncList = this.getSyncableTiddlers();
	currSync.syncTasks = this.createSyncTasks(currSync.syncList);
	this.preProcessSyncableTiddlers(currSync.syncList);
	var wizard = new Wizard();
	currSync.wizard = wizard;
	wizard.createWizard(place,this.wizardTitle);
	wizard.addStep(this.step1Title,this.step1Html);
	var markList = wizard.getElement("markList");
	var listWrapper = document.createElement("div");
	markList.parentNode.insertBefore(listWrapper,markList);
	currSync.listView = ListView.create(listWrapper,currSync.syncList,this.listViewTemplate);
	this.processSyncableTiddlers(currSync.syncList);
	wizard.setButtons([{caption: this.syncLabel, tooltip: this.syncPrompt, onClick: this.doSync}]);
};

config.macros.sync.getSyncableTiddlers = function()
{
	var list = [];
	store.forEachTiddler(function(title,tiddler) {
		var syncItem = {};
		syncItem.serverType = tiddler.getServerType();
		syncItem.serverHost = tiddler.fields['server.host'];
		if(syncItem.serverType && syncItem.serverHost) {
			syncItem.serverWorkspace = tiddler.fields['server.workspace'];
			syncItem.tiddler = tiddler;
			syncItem.title = tiddler.title;
			syncItem.isTouched = tiddler.isTouched();
			syncItem.selected = syncItem.isTouched;
			syncItem.syncStatus = config.macros.sync.syncStatusList[syncItem.isTouched ? "changedLocally" : "none"];
			syncItem.status = syncItem.syncStatus.text;
			list.push(syncItem);
		}
		});
	list.sort(function(a,b) {return a.title < b.title ? -1 : (a.title == b.title ? 0 : +1);});
	return list;
};

config.macros.sync.preProcessSyncableTiddlers = function(syncList)
{
	for(var i=0; i<syncList.length; i++) {
		var si = syncList[i];
		si.serverUrl = si.syncTask.syncMachine.generateTiddlerInfo(si.tiddler).uri;
	}
};

config.macros.sync.processSyncableTiddlers = function(syncList)
{
	for(var i=0; i<syncList.length; i++) {
		var si = syncList[i];
		si.rowElement.style.display = si.syncStatus.display;
		if(si.syncStatus.className)
			si.rowElement.className = si.syncStatus.className;
	}
};

config.macros.sync.createSyncTasks = function(syncList)
{
	var syncTasks = [];
	for(var i=0; i<syncList.length; i++) {
		var si = syncList[i];
		var r = null;
		for(var j=0; j<syncTasks.length; j++) {
			var cst = syncTasks[j];
			if(si.serverType == cst.serverType && si.serverHost == cst.serverHost && si.serverWorkspace == cst.serverWorkspace)
				r = cst;
		}
		if(r) {
			si.syncTask = r;
			r.syncItems.push(si);
		} else {
			si.syncTask = this.createSyncTask(si);
			syncTasks.push(si.syncTask);
		}
	}
	return syncTasks;
};

config.macros.sync.createSyncTask = function(syncItem)
{
	var st = {};
	st.serverType = syncItem.serverType;
	st.serverHost = syncItem.serverHost;
	st.serverWorkspace = syncItem.serverWorkspace;
	st.syncItems = [syncItem];
	st.syncMachine = new SyncMachine(st.serverType,{
		start: function() {
			return this.openHost(st.serverHost,"openWorkspace");
		},
		openWorkspace: function() {
			return this.openWorkspace(st.serverWorkspace,"getTiddlerList");
		},
		getTiddlerList: function() {
			return this.getTiddlerList("onGetTiddlerList");
		},
		onGetTiddlerList: function(context) {
			var tiddlers = context.tiddlers;
			for(var i=0; i<st.syncItems.length; i++) {
				var si = st.syncItems[i];
				var f = tiddlers.findByField("title",si.title);
				if(f !== null) {
					if(tiddlers[f].fields['server.page.revision'] > si.tiddler.fields['server.page.revision']) {
						si.syncStatus = config.macros.sync.syncStatusList[si.isTouched ? 'changedBoth' : 'changedServer'];
					}
				} else {
					si.syncStatus = config.macros.sync.syncStatusList.notFound;
				}
				config.macros.sync.updateSyncStatus(si);
			}
		},
		getTiddler: function(title) {
			return this.getTiddler(title,"onGetTiddler");
		},
		onGetTiddler: function(context) {
			var tiddler = context.tiddler;
			var syncItem = st.syncItems.findByField("title",tiddler.title);
			if(syncItem !== null) {
				syncItem = st.syncItems[syncItem];
				store.saveTiddler(tiddler.title, tiddler.title, tiddler.text, tiddler.modifier, tiddler.modified, tiddler.tags, tiddler.fields, true, tiddler.created);
				syncItem.syncStatus = config.macros.sync.syncStatusList.gotFromServer;
				config.macros.sync.updateSyncStatus(syncItem);
			}
		},
		putTiddler: function(tiddler) {
			return this.putTiddler(tiddler,"onPutTiddler");
		},
		onPutTiddler: function(context) {
			var title = context.title;
			var syncItem = st.syncItems.findByField("title",title);
			if(syncItem !== null) {
				syncItem = st.syncItems[syncItem];
				store.resetTiddler(title);
				if(context.status) {
					syncItem.syncStatus = config.macros.sync.syncStatusList.putToServer;
					config.macros.sync.updateSyncStatus(syncItem);
				}
			}
		}
	});
	st.syncMachine.go();
	return st;
};

config.macros.sync.updateSyncStatus = function(syncItem)
{
	var e = syncItem.colElements["status"];
	removeChildren(e);
	createTiddlyText(e,syncItem.syncStatus.text);
	syncItem.rowElement.style.display = syncItem.syncStatus.display;
	if(syncItem.syncStatus.className)
		syncItem.rowElement.className = syncItem.syncStatus.className;
};

config.macros.sync.doSync = function(e)
{
	var rowNames = ListView.getSelectedRows(currSync.listView);
	var sl = config.macros.sync.syncStatusList;
	for(var i=0; i<currSync.syncList.length; i++) {
		var si = currSync.syncList[i];
		if(rowNames.indexOf(si.title) != -1) {
			var r = true;
			switch(si.syncStatus) {
			case sl.changedServer:
				r = si.syncTask.syncMachine.go("getTiddler",si.title);
				break;
			case sl.notFound:
			case sl.changedLocally:
			case sl.changedBoth:
				r = si.syncTask.syncMachine.go("putTiddler",si.tiddler);
				break;
			default:
				break;
			}
			if(!r)
				displayMessage("Error in doSync: " + r);
		}
	}
	return false;
};

function SyncMachine(serverType,steps)
{
	this.serverType = serverType;
	this.adaptor = new config.adaptors[serverType]();
	this.steps = steps;
}

SyncMachine.prototype.go = function(step,context)
{
	var r = context ? context.status : null;
	if(typeof r == "string") {
		this.invokeError(r);
		return r;
	}
	var h = this.steps[step ? step : "start"];
	if(!h)
		return null;
	r = h.call(this,context);
	if(typeof r == "string")
		this.invokeError(r);
	return r;
};

SyncMachine.prototype.invokeError = function(message)
{
	if(this.steps.error)
		this.steps.error(message);
};

SyncMachine.prototype.openHost = function(host,nextStep)
{
	var me = this;
	return me.adaptor.openHost(host,null,null,function(context) {me.go(nextStep,context);});
};

SyncMachine.prototype.getWorkspaceList = function(nextStep)
{
	var me = this;
	return me.adaptor.getWorkspaceList(null,null,function(context) {me.go(nextStep,context);});
};

SyncMachine.prototype.openWorkspace = function(workspace,nextStep)
{
	var me = this;
	return me.adaptor.openWorkspace(workspace,null,null,function(context) {me.go(nextStep,context);});
};

SyncMachine.prototype.getTiddlerList = function(nextStep)
{
	var me = this;
	return me.adaptor.getTiddlerList(null,null,function(context) {me.go(nextStep,context);});
};

SyncMachine.prototype.generateTiddlerInfo = function(tiddler)
{
	return this.adaptor.generateTiddlerInfo(tiddler);
};

SyncMachine.prototype.getTiddler = function(title,nextStep)
{
	var me = this;
	return me.adaptor.getTiddler(title,null,null,function(context) {me.go(nextStep,context);});
};

SyncMachine.prototype.putTiddler = function(tiddler,nextStep)
{
	var me = this;
	return me.adaptor.putTiddler(tiddler,null,null,function(context) {me.go(nextStep,context);});
};

//--
//-- Manager UI for groups of tiddlers
//--

config.macros.plugins.handler = function(place,macroName,params,wikifier,paramString)
{
	var wizard = new Wizard();
	wizard.createWizard(place,this.wizardTitle);
	wizard.addStep(this.step1Title,this.step1Html);
	var markList = wizard.getElement("markList");
	var listWrapper = document.createElement("div");
	markList.parentNode.insertBefore(listWrapper,markList);
	listWrapper.setAttribute("refresh","macro");
	listWrapper.setAttribute("macroName","plugins");
	listWrapper.setAttribute("params",paramString);
	this.refresh(listWrapper,paramString);
};

config.macros.plugins.refresh = function(listWrapper,params)
{
	var wizard = new Wizard(listWrapper);
	var selectedRows = [];
	ListView.forEachSelector(listWrapper,function(e,rowName) {
			if(e.checked)
				selectedRows.push(e.getAttribute("rowName"));
		});
	removeChildren(listWrapper);
	params = params.parseParams("anon");
	var plugins = installedPlugins.slice(0);
	var t,tiddler,p;
	var configTiddlers = store.getTaggedTiddlers("systemConfig");
	for(t=0; t<configTiddlers.length; t++) {
		tiddler = configTiddlers[t];
		if(plugins.findByField("title",tiddler.title) == null) {
			p = getPluginInfo(tiddler);
			p.executed = false;
			p.log.splice(0,0,this.skippedText);
			plugins.push(p);
		}
	}
	for(t=0; t<plugins.length; t++) {
		p = plugins[t];
		p.size = p.tiddler.text ? p.tiddler.text.length : 0;
		p.forced = p.tiddler.isTagged("systemConfigForce");
		p.disabled = p.tiddler.isTagged("systemConfigDisable");
		p.Selected = selectedRows.indexOf(plugins[t].title) != -1;
	}
	if(plugins.length == 0) {
		createTiddlyElement(listWrapper,"em",null,null,this.noPluginText);
		wizard.setButtons([]);
	} else {
		var listView = ListView.create(listWrapper,plugins,this.listViewTemplate,this.onSelectCommand);
		wizard.setValue("listView",listView);
		wizard.setButtons([
				{caption: config.macros.plugins.removeLabel, tooltip: config.macros.plugins.removePrompt, onClick: config.macros.plugins.doRemoveTag},
				{caption: config.macros.plugins.deleteLabel, tooltip: config.macros.plugins.deletePrompt, onClick: config.macros.plugins.doDelete}
			]);
	}
};

config.macros.plugins.doRemoveTag = function(e)
{
	var wizard = new Wizard(this);
	var listView = wizard.getValue("listView");
	var rowNames = ListView.getSelectedRows(listView);
	if(rowNames.length == 0) {
		alert(config.messages.nothingSelected);
	} else {
		for(var t=0; t<rowNames.length; t++)
			store.setTiddlerTag(rowNames[t],false,"systemConfig");
	}
};

config.macros.plugins.doDelete = function(e)
{
	var wizard = new Wizard(this);
	var listView = wizard.getValue("listView");
	var rowNames = ListView.getSelectedRows(listView);
	if(rowNames.length == 0) {
		alert(config.messages.nothingSelected);
	} else {
		if(confirm(config.macros.plugins.confirmDeleteText.format([rowNames.join(", ")]))) {
			for(var t=0; t<rowNames.length; t++) {
				store.removeTiddler(rowNames[t]);
				story.closeTiddler(rowNames[t],true);
			}
		}
	}
};

//--
//-- Message area
//--

function getMessageDiv()
{
	var msgArea = document.getElementById("messageArea");
	if(!msgArea)
		return null;
	if(!msgArea.hasChildNodes())
		createTiddlyButton(createTiddlyElement(msgArea,"div",null,"messageToolbar"),
			config.messages.messageClose.text,
			config.messages.messageClose.tooltip,
			clearMessage);
	msgArea.style.display = "block";
	return createTiddlyElement(msgArea,"div");
}

function displayMessage(text,linkText)
{
	var e = getMessageDiv();
	if(!e) {
		alert(text);
		return;
	}
	if(linkText) {
		var link = createTiddlyElement(e,"a",null,null,text);
		link.href = linkText;
		link.target = "_blank";
	} else {
		e.appendChild(document.createTextNode(text));
	}
}

function clearMessage()
{
	var msgArea = document.getElementById("messageArea");
	if(msgArea) {
		removeChildren(msgArea);
		msgArea.style.display = "none";
	}
	return false;
}

//--
//-- Refresh mechanism
//--

config.notifyTiddlers = [
	{name: "StyleSheetLayout", notify: refreshStyles},
	{name: "StyleSheetColors", notify: refreshStyles},
	{name: "StyleSheet", notify: refreshStyles},
	{name: "StyleSheetPrint", notify: refreshStyles},
	{name: "PageTemplate", notify: refreshPageTemplate},
	{name: "SiteTitle", notify: refreshPageTitle},
	{name: "SiteSubtitle", notify: refreshPageTitle},
	{name: "ColorPalette", notify: refreshColorPalette},
	{name: null, notify: refreshDisplay}
];

config.refreshers = {
	link: function(e,changeList)
		{
		var title = e.getAttribute("tiddlyLink");
		refreshTiddlyLink(e,title);
		return true;
		},

	tiddler: function(e,changeList)
		{
		var title = e.getAttribute("tiddler");
		var template = e.getAttribute("template");
		if(changeList && changeList.indexOf(title) != -1 && !story.isDirty(title))
			story.refreshTiddler(title,template,true);
		else
			refreshElements(e,changeList);
		return true;
		},

	content: function(e,changeList)
		{
		var title = e.getAttribute("tiddler");
		var force = e.getAttribute("force");
		if(force != null || changeList == null || changeList.indexOf(title) != -1) {
			removeChildren(e);
			wikify(store.getTiddlerText(title,""),e,null,store.fetchTiddler(title));
			return true;
		} else
			return false;
		},

	macro: function(e,changeList)
		{
		var macro = e.getAttribute("macroName");
		var params = e.getAttribute("params");
		if(macro)
			macro = config.macros[macro];
		if(macro && macro.refresh)
			macro.refresh(e,params);
		return true;
		}
};

config.refresherData = {
	styleSheet: "StyleSheet",
	defaultStyleSheet: "StyleSheet",
	pageTemplate: "PageTemplate",
	defaultPageTemplate: "PageTemplate",
	colorPalette: "ColorPalette",
	defaultColorPalette: "ColorPalette"
};

function refreshElements(root,changeList)
{
	var nodes = root.childNodes;
	for(var c=0; c<nodes.length; c++) {
		var e = nodes[c], type = null;
		if(e.getAttribute && (e.tagName ? e.tagName != "IFRAME" : true))
			type = e.getAttribute("refresh");
		var refresher = config.refreshers[type];
		var refreshed = false;
		if(refresher != undefined)
			refreshed = refresher(e,changeList);
		if(e.hasChildNodes() && !refreshed)
			refreshElements(e,changeList);
	}
}

function applyHtmlMacros(root,tiddler)
{
	var e = root.firstChild;
	while(e) {
		var nextChild = e.nextSibling;
		if(e.getAttribute) {
			var macro = e.getAttribute("macro");
			if(macro) {
				e.removeAttribute("macro");
				var params = "";
				var p = macro.indexOf(" ");
				if(p != -1) {
					params = macro.substr(p+1);
					macro = macro.substr(0,p);
				}
				invokeMacro(e,macro,params,null,tiddler);
			}
		}
		if(e.hasChildNodes())
			applyHtmlMacros(e,tiddler);
		e = nextChild;
	}
}

function refreshPageTemplate(title)
{
	var stash = createTiddlyElement(document.body,"div");
	stash.style.display = "none";
	var display = story.getContainer();
	var nodes,t;
	if(display) {
		nodes = display.childNodes;
		for(t=nodes.length-1; t>=0; t--)
			stash.appendChild(nodes[t]);
	}
	var wrapper = document.getElementById("contentWrapper");

	var isAvailable = function(title) {
		var s = title ? title.indexOf(config.textPrimitives.sectionSeparator) : -1;
		if(s!=-1)
			title = title.substr(0,s);
		return store.tiddlerExists(title) || store.isShadowTiddler(title);
	};
	if(!title || !isAvailable(title))
		title = config.refresherData.pageTemplate;
	if(!isAvailable(title))
		title = config.refresherData.defaultPageTemplate; //# this one is always avaialable
	wrapper.innerHTML = store.getRecursiveTiddlerText(title,null,10);
	applyHtmlMacros(wrapper);
	refreshElements(wrapper);
	display = story.getContainer();
	removeChildren(display);
	if(!display)
		display = createTiddlyElement(wrapper,"div",story.containerId());
	nodes = stash.childNodes;
	for(t=nodes.length-1; t>=0; t--)
		display.appendChild(nodes[t]);
	removeNode(stash);
}

function refreshDisplay(hint)
{
	if(typeof hint == "string")
		hint = [hint];
	var e = document.getElementById("contentWrapper");
	refreshElements(e,hint);
	if(backstage.isPanelVisible()) {
		e = document.getElementById("backstage");
		refreshElements(e,hint);
	}
}

function refreshPageTitle()
{
	document.title = getPageTitle();
}

function getPageTitle()
{
	var st = wikifyPlain("SiteTitle");
	var ss = wikifyPlain("SiteSubtitle");
	return st + ((st == "" || ss == "") ? "" : " - ") + ss;
}

function refreshStyles(title,doc)
{
	setStylesheet(title == null ? "" : store.getRecursiveTiddlerText(title,"",10),title,doc || document);
}

function refreshColorPalette(title)
{
	if(!startingUp)
		refreshAll();
}

function refreshAll()
{
	refreshPageTemplate();
	refreshDisplay();
	refreshStyles("StyleSheetLayout");
	refreshStyles("StyleSheetColors");
	refreshStyles(config.refresherData.styleSheet);
	refreshStyles("StyleSheetPrint");
}

//--
//-- Options stuff
//--

config.optionHandlers = {
	'txt': {
		get: function(name) {return encodeCookie(config.options[name].toString());},
		set: function(name,value) {config.options[name] = decodeCookie(value);}
	},
	'chk': {
		get: function(name) {return config.options[name] ? "true" : "false";},
		set: function(name,value) {config.options[name] = value == "true";}
	}
};

function loadOptionsCookie()
{
	if(safeMode)
		return;
	var cookies = document.cookie.split(";");
	for(var c=0; c<cookies.length; c++) {
		var p = cookies[c].indexOf("=");
		if(p != -1) {
			var name = cookies[c].substr(0,p).trim();
			var value = cookies[c].substr(p+1).trim();
			var optType = name.substr(0,3);
			if(config.optionHandlers[optType] && config.optionHandlers[optType].set)
				config.optionHandlers[optType].set(name,value);
		}
	}
}

function saveOptionCookie(name)
{
	if(safeMode)
		return;
	var c = name + "=";
	var optType = name.substr(0,3);
	if(config.optionHandlers[optType] && config.optionHandlers[optType].get)
		c += config.optionHandlers[optType].get(name);
	c += "; expires=Fri, 1 Jan 2038 12:00:00 UTC; path=/";
	document.cookie = c;
}

function encodeCookie(s)
{
	return escape(convertUnicodeToHtmlEntities(s));
}

function decodeCookie(s)
{
	s = unescape(s);
	var re = /&#[0-9]{1,5};/g;
	return s.replace(re,function($0) {return String.fromCharCode(eval($0.replace(/[&#;]/g,"")));});
}


config.macros.option.genericCreate = function(place,type,opt,className,desc)
{
	var typeInfo = config.macros.option.types[type];
	var c = document.createElement(typeInfo.elementType);
	if(typeInfo.typeValue)
		c.setAttribute("type",typeInfo.typeValue);
	c[typeInfo.eventName] = typeInfo.onChange;
	c.setAttribute("option",opt);
	c.className = className || typeInfo.className;
	if(config.optionsDesc[opt])
		c.setAttribute("title",config.optionsDesc[opt]);
	place.appendChild(c);
	if(desc != "no")
		createTiddlyText(place,config.optionsDesc[opt] || opt);
	c[typeInfo.valueField] = config.options[opt];
	return c;
};

config.macros.option.genericOnChange = function(e)
{
	var opt = this.getAttribute("option");
	if(opt) {
		var optType = opt.substr(0,3);
		var handler = config.macros.option.types[optType];
		if(handler.elementType && handler.valueField)
			config.macros.option.propagateOption(opt,handler.valueField,this[handler.valueField],handler.elementType,this);
	}
	return true;
};

config.macros.option.types = {
	'txt': {
		elementType: "input",
		valueField: "value",
		eventName: "onchange",
		className: "txtOptionInput",
		create: config.macros.option.genericCreate,
		onChange: config.macros.option.genericOnChange
	},
	'chk': {
		elementType: "input",
		valueField: "checked",
		eventName: "onclick",
		className: "chkOptionInput",
		typeValue: "checkbox",
		create: config.macros.option.genericCreate,
		onChange: config.macros.option.genericOnChange
	}
};

config.macros.option.propagateOption = function(opt,valueField,value,elementType,elem)
{
	config.options[opt] = value;
	saveOptionCookie(opt);
	var nodes = document.getElementsByTagName(elementType);
	for(var t=0; t<nodes.length; t++) {
		var optNode = nodes[t].getAttribute("option");
		if(opt == optNode && nodes[t]!=elem)
			nodes[t][valueField] = value;
	}
};

config.macros.option.handler = function(place,macroName,params,wikifier,paramString)
{
	params = paramString.parseParams("anon",null,true,false,false);
	var opt = (params[1] && params[1].name == "anon") ? params[1].value : getParam(params,"name",null);
	var className = (params[2] && params[2].name == "anon") ? params[2].value : getParam(params,"class",null);
	var desc = getParam(params,"desc","no");
	var type = opt.substr(0,3);
	var h = config.macros.option.types[type];
	if(h && h.create)
		h.create(place,type,opt,className,desc);
};

config.macros.options.handler = function(place,macroName,params,wikifier,paramString)
{
	params = paramString.parseParams("anon",null,true,false,false);
	var showUnknown = getParam(params,"showUnknown","no");
	var wizard = new Wizard();
	wizard.createWizard(place,this.wizardTitle);
	wizard.addStep(this.step1Title,this.step1Html);
	var markList = wizard.getElement("markList");
	var chkUnknown = wizard.getElement("chkUnknown");
	chkUnknown.checked = showUnknown == "yes";
	chkUnknown.onchange = this.onChangeUnknown;
	var listWrapper = document.createElement("div");
	markList.parentNode.insertBefore(listWrapper,markList);
	wizard.setValue("listWrapper",listWrapper);
	this.refreshOptions(listWrapper,showUnknown == "yes");
};

config.macros.options.refreshOptions = function(listWrapper,showUnknown)
{
	var opts = [];
	for(var n in config.options) {
		var opt = {};
		opt.option = "";
		opt.name = n;
		opt.lowlight = !config.optionsDesc[n];
		opt.description = opt.lowlight ? this.unknownDescription : config.optionsDesc[n];
		if(!opt.lowlight || showUnknown)
			opts.push(opt);
	}
	opts.sort(function(a,b) {return a.name.substr(3) < b.name.substr(3) ? -1 : (a.name.substr(3) == b.name.substr(3) ? 0 : +1);});
	var listview = ListView.create(listWrapper,opts,this.listViewTemplate);
	for(n=0; n<opts.length; n++) {
		var type = opts[n].name.substr(0,3);
		var h = config.macros.option.types[type];
		if(h && h.create) {
			h.create(opts[n].colElements['option'],type,opts[n].name,null,"no");
		}
	}
};

config.macros.options.onChangeUnknown = function(e)
{
	var wizard = new Wizard(this);
	var listWrapper = wizard.getValue("listWrapper");
	removeChildren(listWrapper);
	config.macros.options.refreshOptions(listWrapper,this.checked);
	return false;
};

//--
//-- Saving
//--

var saveUsingSafari = false;

var startSaveArea = '<div id="' + 'storeArea">'; // Split up into two so that indexOf() of this source doesn't find it
var endSaveArea = '</d' + 'iv>';

// If there are unsaved changes, force the user to confirm before exitting
function confirmExit()
{
	hadConfirmExit = true;
	if((store && store.isDirty && store.isDirty()) || (story && story.areAnyDirty && story.areAnyDirty()))
		return config.messages.confirmExit;
}

// Give the user a chance to save changes before exitting
function checkUnsavedChanges()
{
	if(store && store.isDirty && store.isDirty() && window.hadConfirmExit === false) {
		if(confirm(config.messages.unsavedChangesWarning))
			saveChanges();
	}
}

function updateLanguageAttribute(s)
{
	if(config.locale) {
		var mRE = /(<html(?:.*?)?)(?: xml:lang\="([a-z]+)")?(?: lang\="([a-z]+)")?>/;
		var m = mRE.exec(s);
		if(m) {
			var t = m[1];
			if(m[2])
				t += ' xml:lang="' + config.locale + '"';
			if(m[3])
				t += ' lang="' + config.locale + '"';
			t += ">";
			s = s.substr(0,m.index) + t + s.substr(m.index+m[0].length);
		}
	}
	return s;
}

function updateMarkupBlock(s,blockName,tiddlerName)
{
	return s.replaceChunk(
			"<!--%0-START-->".format([blockName]),
			"<!--%0-END-->".format([blockName]),
			"\n" + convertUnicodeToFileFormat(store.getRecursiveTiddlerText(tiddlerName,"")) + "\n");
}

function updateOriginal(original,posDiv,localPath)
{
	if(!posDiv)
		posDiv = locateStoreArea(original);
	if(!posDiv) {
		alert(config.messages.invalidFileError.format([localPath]));
		return null;
	}
	var revised = original.substr(0,posDiv[0] + startSaveArea.length) + "\n" +
				convertUnicodeToFileFormat(store.allTiddlersAsHtml()) + "\n" +
				original.substr(posDiv[1]);
	var newSiteTitle = convertUnicodeToFileFormat(getPageTitle()).htmlEncode();
	revised = revised.replaceChunk("<title"+">","</title"+">"," " + newSiteTitle + " ");
	revised = updateLanguageAttribute(revised);
	revised = updateMarkupBlock(revised,"PRE-HEAD","MarkupPreHead");
	revised = updateMarkupBlock(revised,"POST-HEAD","MarkupPostHead");
	revised = updateMarkupBlock(revised,"PRE-BODY","MarkupPreBody");
	revised = updateMarkupBlock(revised,"POST-SCRIPT","MarkupPostBody");
	return revised;
}

function locateStoreArea(original)
{
	// Locate the storeArea div's
	var posOpeningDiv = original.indexOf(startSaveArea);
	var limitClosingDiv = original.indexOf("<"+"!--POST-STOREAREA--"+">");
	if(limitClosingDiv == -1)
		limitClosingDiv = original.indexOf("<"+"!--POST-BODY-START--"+">");
	var posClosingDiv = original.lastIndexOf(endSaveArea,limitClosingDiv == -1 ? original.length : limitClosingDiv);
	return (posOpeningDiv != -1 && posClosingDiv != -1) ? [posOpeningDiv,posClosingDiv] : null;
}

function autoSaveChanges(onlyIfDirty,tiddlers)
{
	if(config.options.chkAutoSave)
		saveChanges(onlyIfDirty,tiddlers);
}

function loadOriginal(localPath)
{
	return loadFile(localPath);
}

// Save this tiddlywiki with the pending changes
function saveChanges(onlyIfDirty,tiddlers)
{
	if(onlyIfDirty && !store.isDirty())
		return;
	clearMessage();
	var t0 = new Date();
	var originalPath = document.location.toString();
	if(originalPath.substr(0,5) != "file:") {
		alert(config.messages.notFileUrlError);
		if(store.tiddlerExists(config.messages.saveInstructions))
			story.displayTiddler(null,config.messages.saveInstructions);
		return;
	}
	var localPath = getLocalPath(originalPath);
	var original = loadOriginal(localPath);
	if(original == null) {
		alert(config.messages.cantSaveError);
		if(store.tiddlerExists(config.messages.saveInstructions))
			story.displayTiddler(null,config.messages.saveInstructions);
		return;
	}
	var posDiv = locateStoreArea(original);
	if(!posDiv) {
		alert(config.messages.invalidFileError.format([localPath]));
		return;
	}
	saveMain(localPath,original,posDiv);
	if(config.options.chkSaveBackups)
		saveBackup(localPath,original);
	if(config.options.chkSaveEmptyTemplate)
		saveEmpty(localPath,original,posDiv);
	if(config.options.chkGenerateAnRssFeed && saveRss instanceof Function)
		saveRss(localPath);
	if(config.options.chkDisplayInstrumentation)
		displayMessage("saveChanges " + (new Date()-t0) + " ms");
}

function saveMain(localPath,original,posDiv)
{
	var save;
	try {
		var revised = updateOriginal(original,posDiv,localPath);
		save = saveFile(localPath,revised);
	} catch (ex) {
		showException(ex);
	}
	if(save) {
		displayMessage(config.messages.mainSaved,"file://" + localPath);
		store.setDirty(false);
	} else {
		alert(config.messages.mainFailed);
	}
}

function saveBackup(localPath,original)
{
	var backupPath = getBackupPath(localPath);
	var backup = copyFile(backupPath,localPath);
	if(!backup)
		backup = saveFile(backupPath,original);
	if(backup)
		displayMessage(config.messages.backupSaved,"file://" + backupPath);
	else
		alert(config.messages.backupFailed);
}

function saveEmpty(localPath,original,posDiv)
{
	var emptyPath,p;
	if((p = localPath.lastIndexOf("/")) != -1)
		emptyPath = localPath.substr(0,p) + "/";
	else if((p = localPath.lastIndexOf("\\")) != -1)
		emptyPath = localPath.substr(0,p) + "\\";
	else
		emptyPath = localPath + ".";
	emptyPath += "empty.html";
	var empty = original.substr(0,posDiv[0] + startSaveArea.length) + original.substr(posDiv[1]);
	var emptySave = saveFile(emptyPath,empty);
	if(emptySave)
		displayMessage(config.messages.emptySaved,"file://" + emptyPath);
	else
		alert(config.messages.emptyFailed);
}

function getLocalPath(origPath)
{
	var originalPath = convertUriToUTF8(origPath,config.options.txtFileSystemCharSet);
	// Remove any location or query part of the URL
	var argPos = originalPath.indexOf("?");
	if(argPos != -1)
		originalPath = originalPath.substr(0,argPos);
	var hashPos = originalPath.indexOf("#");
	if(hashPos != -1)
		originalPath = originalPath.substr(0,hashPos);
	// Convert file://localhost/ to file:///
	if(originalPath.indexOf("file://localhost/") == 0)
		originalPath = "file://" + originalPath.substr(16);
	// Convert to a native file format
	var localPath;
	if(originalPath.charAt(9) == ":") // pc local file
		localPath = unescape(originalPath.substr(8)).replace(new RegExp("/","g"),"\\");
	else if(originalPath.indexOf("file://///") == 0) // FireFox pc network file
		localPath = "\\\\" + unescape(originalPath.substr(10)).replace(new RegExp("/","g"),"\\");
	else if(originalPath.indexOf("file:///") == 0) // mac/unix local file
		localPath = unescape(originalPath.substr(7));
	else if(originalPath.indexOf("file:/") == 0) // mac/unix local file
		localPath = unescape(originalPath.substr(5));
	else // pc network file
		localPath = "\\\\" + unescape(originalPath.substr(7)).replace(new RegExp("/","g"),"\\");
	return localPath;
}

function getBackupPath(localPath,title,extension)
{
	var slash = "\\";
	var dirPathPos = localPath.lastIndexOf("\\");
	if(dirPathPos == -1) {
		dirPathPos = localPath.lastIndexOf("/");
		slash = "/";
	}
	var backupFolder = config.options.txtBackupFolder;
	if(!backupFolder || backupFolder == "")
		backupFolder = ".";
	var backupPath = localPath.substr(0,dirPathPos) + slash + backupFolder + localPath.substr(dirPathPos);
	backupPath = backupPath.substr(0,backupPath.lastIndexOf(".")) + ".";
	if(title)
		backupPath += title.replace(/[\\\/\*\?\":<> ]/g,"_") + ".";
	backupPath += (new Date()).convertToYYYYMMDDHHMMSSMMM() + "." + (extension || "html");
	return backupPath;
}

//--
//-- RSS Saving
//--

function saveRss(localPath)
{
	var rssPath = localPath.substr(0,localPath.lastIndexOf(".")) + ".xml";
	if(saveFile(rssPath,convertUnicodeToFileFormat(generateRss())))
		displayMessage(config.messages.rssSaved,"file://" + rssPath);
	else
		alert(config.messages.rssFailed);
}

function generateRss()
{
	var s = [];
	var d = new Date();
	var u = store.getTiddlerText("SiteUrl");
	// Assemble the header
	s.push("<" + "?xml version=\"1.0\"?" + ">");
	s.push("<rss version=\"2.0\">");
	s.push("<channel>");
	s.push("<title" + ">" + wikifyPlain("SiteTitle").htmlEncode() + "</title" + ">");
	if(u)
		s.push("<link>" + u.htmlEncode() + "</link>");
	s.push("<description>" + wikifyPlain("SiteSubtitle").htmlEncode() + "</description>");
	s.push("<language>" + config.locale + "</language>");
	s.push("<copyright>Copyright " + d.getFullYear() + " " + config.options.txtUserName.htmlEncode() + "</copyright>");
	s.push("<pubDate>" + d.toGMTString() + "</pubDate>");
	s.push("<lastBuildDate>" + d.toGMTString() + "</lastBuildDate>");
	s.push("<docs>http://blogs.law.harvard.edu/tech/rss</docs>");
	s.push("<generator>TiddlyWiki " + formatVersion() + "</generator>");
	// The body
	var tiddlers = store.getTiddlers("modified","excludeLists");
	var n = config.numRssItems > tiddlers.length ? 0 : tiddlers.length-config.numRssItems;
	for(var t=tiddlers.length-1; t>=n; t--) {
		s.push("<item>\n" + tiddlers[t].toRssItem(u) + "\n</item>");
	}
	// And footer
	s.push("</channel>");
	s.push("</rss>");
	// Save it all
	return s.join("\n");
}

//--
//-- Filesystem code
//--

function convertUTF8ToUnicode(u)
{
	return config.browser.isOpera || !window.netscape ? manualConvertUTF8ToUnicode(u) : mozConvertUTF8ToUnicode(u);
}

function manualConvertUTF8ToUnicode(utf)
{
	var uni = utf;
	var src = 0;
	var dst = 0;
	var b1, b2, b3;
	var c;
	while(src < utf.length) {
		b1 = utf.charCodeAt(src++);
		if(b1 < 0x80) {
			dst++;
		} else if(b1 < 0xE0) {
			b2 = utf.charCodeAt(src++);
			c = String.fromCharCode(((b1 & 0x1F) << 6) | (b2 & 0x3F));
			uni = uni.substring(0,dst++).concat(c,utf.substr(src));
		} else {
			b2 = utf.charCodeAt(src++);
			b3 = utf.charCodeAt(src++);
			c = String.fromCharCode(((b1 & 0xF) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F));
			uni = uni.substring(0,dst++).concat(c,utf.substr(src));
		}
	}
	return uni;
}

function mozConvertUTF8ToUnicode(u)
{
	try {
		netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
		var converter = Components.classes["@mozilla.org/intl/scriptableunicodeconverter"].createInstance(Components.interfaces.nsIScriptableUnicodeConverter);
		converter.charset = "UTF-8";
	} catch(ex) {
		return manualConvertUTF8ToUnicode(u);
	} // fallback
	var s = converter.ConvertToUnicode(u);
	var fin = converter.Finish();
	return fin.length > 0 ? s+fin : s;
}

function convertUnicodeToFileFormat(s)
{
	return config.browser.isOpera || !window.netscape ? convertUnicodeToHtmlEntities(s) : mozConvertUnicodeToUTF8(s);
}

function convertUnicodeToHtmlEntities(s)
{
	var re = /[^\u0000-\u007F]/g;
	return s.replace(re,function($0) {return "&#" + $0.charCodeAt(0).toString() + ";";});
}

function convertUnicodeToUTF8(s)
{
// return convertUnicodeToFileFormat to allow plugin migration
	return convertUnicodeToFileFormat(s);
}

function manualConvertUnicodeToUTF8(s)
{
	return unescape(encodeURIComponent(s));
}

function mozConvertUnicodeToUTF8(s)
{
	try {
		netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
		var converter = Components.classes["@mozilla.org/intl/scriptableunicodeconverter"].createInstance(Components.interfaces.nsIScriptableUnicodeConverter);
		converter.charset = "UTF-8";
	} catch(ex) {
		return manualConvertUnicodeToUTF8(s);
	} // fallback
	var u = converter.ConvertFromUnicode(s);
	var fin = converter.Finish();
	return fin.length > 0 ? u + fin : u;
}

function convertUriToUTF8(uri,charSet)
{
	if(window.netscape == undefined || charSet == undefined || charSet == "")
		return uri;
	try {
		netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
		var converter = Components.classes["@mozilla.org/intl/utf8converterservice;1"].getService(Components.interfaces.nsIUTF8ConverterService);
	} catch(ex) {
		return uri;
	}
	return converter.convertURISpecToUTF8(uri,charSet);
}

function copyFile(dest,source)
{
	return config.browser.isIE ? ieCopyFile(dest,source) : false;
}

function saveFile(fileUrl,content)
{
	var r = mozillaSaveFile(fileUrl,content);
	if(!r)
		r = ieSaveFile(fileUrl,content);
	if(!r)
		r = javaSaveFile(fileUrl,content);
	return r;
}

function loadFile(fileUrl)
{
	var r = mozillaLoadFile(fileUrl);
	if((r == null) || (r == false))
		r = ieLoadFile(fileUrl);
	if((r == null) || (r == false))
		r = javaLoadFile(fileUrl);
	return r;
}

function ieCreatePath(path)
{
	try {
		var fso = new ActiveXObject("Scripting.FileSystemObject");
	} catch(ex) {
		return null;
	}

	var pos = path.lastIndexOf("\\");
	if(pos!=-1)
		path = path.substring(0,pos+1);

	var scan = [path];
	var parent = fso.GetParentFolderName(path);
	while(parent && !fso.FolderExists(parent)) {
		scan.push(parent);
		parent = fso.GetParentFolderName(parent);
	}

	for(i=scan.length-1;i>=0;i--) {
		if(!fso.FolderExists(scan[i])) {
			fso.CreateFolder(scan[i]);
		}
	}
	return true;
}

// Returns null if it can't do it, false if there's an error, true if it saved OK
function ieSaveFile(filePath,content)
{
	ieCreatePath(filePath);
	try {
		var fso = new ActiveXObject("Scripting.FileSystemObject");
	} catch(ex) {
		return null;
	}
	var file = fso.OpenTextFile(filePath,2,-1,0);
	file.Write(content);
	file.Close();
	return true;
}

// Returns null if it can't do it, false if there's an error, or a string of the content if successful
function ieLoadFile(filePath)
{
	try {
		var fso = new ActiveXObject("Scripting.FileSystemObject");
		var file = fso.OpenTextFile(filePath,1);
		var content = file.ReadAll();
		file.Close();
	} catch(ex) {
		return null;
	}
	return content;
}

function ieCopyFile(dest,source)
{
	ieCreatePath(dest);
	try {
		var fso = new ActiveXObject("Scripting.FileSystemObject");
		fso.GetFile(source).Copy(dest);
	} catch(ex) {
		return false;
	}
	return true;
}

// Returns null if it can't do it, false if there's an error, true if it saved OK
function mozillaSaveFile(filePath,content)
{
	if(window.Components) {
		try {
			netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
			var file = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
			file.initWithPath(filePath);
			if(!file.exists())
				file.create(0,0664);
			var out = Components.classes["@mozilla.org/network/file-output-stream;1"].createInstance(Components.interfaces.nsIFileOutputStream);
			out.init(file,0x20|0x02,00004,null);
			out.write(content,content.length);
			out.flush();
			out.close();
			return true;
		} catch(ex) {
			return false;
		}
	}
	return null;
}

// Returns null if it can't do it, false if there's an error, or a string of the content if successful
function mozillaLoadFile(filePath)
{
	if(window.Components) {
		try {
			netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
			var file = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
			file.initWithPath(filePath);
			if(!file.exists())
				return null;
			var inputStream = Components.classes["@mozilla.org/network/file-input-stream;1"].createInstance(Components.interfaces.nsIFileInputStream);
			inputStream.init(file,0x01,00004,null);
			var sInputStream = Components.classes["@mozilla.org/scriptableinputstream;1"].createInstance(Components.interfaces.nsIScriptableInputStream);
			sInputStream.init(inputStream);
			var contents = sInputStream.read(sInputStream.available());
			sInputStream.close();
			inputStream.close();
			return contents;
		} catch(ex) {
			return false;
		}
	}
	return null;
}

function javaUrlToFilename(url)
{
	var f = "//localhost";
	if(url.indexOf(f) == 0)
		return url.substring(f.length);
	var i = url.indexOf(":");
	return i > 0 ? url.substring(i-1) : url;
}

function javaSaveFile(filePath,content)
{
	try {
		if(document.applets["TiddlySaver"])
			return document.applets["TiddlySaver"].saveFile(javaUrlToFilename(filePath),"UTF-8",content);
	} catch(ex) {
	}
	try {
		var s = new java.io.PrintStream(new java.io.FileOutputStream(javaUrlToFilename(filePath)));
		s.print(content);
		s.close();
	} catch(ex) {
		return null;
	}
	return true;
}

function javaLoadFile(filePath)
{
	try {
		if(document.applets["TiddlySaver"])
			return String(document.applets["TiddlySaver"].loadFile(javaUrlToFilename(filePath),"UTF-8"));
	} catch(ex) {
	}
	var content = [];
	try {
		var r = new java.io.BufferedReader(new java.io.FileReader(javaUrlToFilename(filePath)));
		var line;
		while((line = r.readLine()) != null)
			content.push(new String(line));
		r.close();
	} catch(ex) {
		return null;
	}
	return content.join("\n");
}

//--
//-- Server adaptor base class
//--

function AdaptorBase()
{
	this.host = null;
	this.store = null;
	return this;
}

AdaptorBase.prototype.close = function()
{
	return true;
};

AdaptorBase.prototype.fullHostName = function(host)
{
	if(!host)
		return '';
	host = host.trim();
	if(!host.match(/:\/\//))
		host = 'http://' + host;
	if(host.substr(host.length-1) == '/')
		host = host.substr(0,host.length-1)
	return host;
};

AdaptorBase.minHostName = function(host)
{
	return host ? host.replace(/^http:\/\//,'').replace(/\/$/,'') : '';
};

AdaptorBase.prototype.setContext = function(context,userParams,callback)
{
	if(!context) context = {};
	context.userParams = userParams;
	if(callback) context.callback = callback;
	context.adaptor = this;
	if(!context.host)
		context.host = this.host;
	context.host = this.fullHostName(context.host);
	if(!context.workspace)
		context.workspace = this.workspace;
	return context;
};

// Open the specified host
AdaptorBase.prototype.openHost = function(host,context,userParams,callback)
{
	this.host = host;
	context = this.setContext(context,userParams,callback);
	context.status = true;
	if(callback)
		window.setTimeout(function() {context.callback(context,userParams);},10);
	return true;
};

// Open the specified workspace
AdaptorBase.prototype.openWorkspace = function(workspace,context,userParams,callback)
{
	this.workspace = workspace;
	context = this.setContext(context,userParams,callback);
	context.status = true;
	if(callback)
		window.setTimeout(function() {callback(context,userParams);},10);
	return true;
};

//--
//-- Server adaptor for talking to static TiddlyWiki files
//--

function FileAdaptor()
{
}

FileAdaptor.prototype = new AdaptorBase();

FileAdaptor.serverType = 'file';
FileAdaptor.serverLabel = 'TiddlyWiki';

FileAdaptor.loadTiddlyWikiCallback = function(status,context,responseText,url,xhr)
{
	context.status = status;
	if(!status) {
		context.statusText = "Error reading file";
	} else {
		context.adaptor.store = new TiddlyWiki();
		if(!context.adaptor.store.importTiddlyWiki(responseText)) {
			context.statusText = config.messages.invalidFileError.format([url]);
			context.status = false;
		}
	}
	context.complete(context,context.userParams);
};

// Get the list of workspaces on a given server
FileAdaptor.prototype.getWorkspaceList = function(context,userParams,callback)
{
	context = this.setContext(context,userParams,callback);
	context.workspaces = [{title:"(default)"}];
	context.status = true;
	if(callback)
		window.setTimeout(function() {callback(context,userParams);},10);
	return true;
};

// Gets the list of tiddlers within a given workspace
FileAdaptor.prototype.getTiddlerList = function(context,userParams,callback,filter)
{
	context = this.setContext(context,userParams,callback);
	if(!context.filter)
		context.filter = filter;
	context.complete = FileAdaptor.getTiddlerListComplete;
	if(this.store) {
		var ret = context.complete(context,context.userParams);
	} else {
		ret = loadRemoteFile(context.host,FileAdaptor.loadTiddlyWikiCallback,context);
		if(typeof ret != "string")
			ret = true;
	}
	return ret;
};

FileAdaptor.getTiddlerListComplete = function(context,userParams)
{
	if(context.status) {
		if(context.filter) {
			context.tiddlers = context.adaptor.store.filterTiddlers(context.filter);
		} else {
			context.tiddlers = [];
			context.adaptor.store.forEachTiddler(function(title,tiddler) {context.tiddlers.push(tiddler);});
		}
		for(var i=0; i<context.tiddlers.length; i++) {
			context.tiddlers[i].fields['server.type'] = FileAdaptor.serverType;
			context.tiddlers[i].fields['server.host'] = AdaptorBase.minHostName(context.host);
			context.tiddlers[i].fields['server.page.revision'] = context.tiddlers[i].modified.convertToYYYYMMDDHHMM();
		}
		context.status = true;
	}
	if(context.callback) {
		window.setTimeout(function() {context.callback(context,userParams);},10);
	}
	return true;
};

FileAdaptor.prototype.generateTiddlerInfo = function(tiddler)
{
	var info = {};
	info.uri = tiddler.fields['server.host'] + "#" + tiddler.title;
	return info;
};

// Retrieve a tiddler from a given workspace on a given server
FileAdaptor.prototype.getTiddler = function(title,context,userParams,callback)
{
	context = this.setContext(context,userParams,callback);
	context.title = title;
	context.complete = FileAdaptor.getTiddlerComplete;
	return context.adaptor.store ?
		context.complete(context,context.userParams) :
		loadRemoteFile(context.host,FileAdaptor.loadTiddlyWikiCallback,context);
};

FileAdaptor.getTiddlerComplete = function(context,userParams)
{
	var t = context.adaptor.store.fetchTiddler(context.title);
	t.fields['server.type'] = FileAdaptor.serverType;
	t.fields['server.host'] = AdaptorBase.minHostName(context.host);
	t.fields['server.page.revision'] = t.modified.convertToYYYYMMDDHHMM();
	context.tiddler = t;
	context.status = true;
	if(context.allowSynchronous) {
		context.isSynchronous = true;
		context.callback(context,userParams);
	} else {
		window.setTimeout(function() {context.callback(context,userParams);},10);
	}
	return true;
};

FileAdaptor.prototype.close = function()
{
	delete this.store;
	this.store = null;
};

config.adaptors[FileAdaptor.serverType] = FileAdaptor;

config.defaultAdaptor = FileAdaptor.serverType;

//--
//-- Remote HTTP requests
//--

function loadRemoteFile(url,callback,params)
{
	return httpReq("GET",url,callback,params);
}

function httpReq(type,url,callback,params,headers,data,contentType,username,password,allowCache)
{
	var x = null;
	try {
		x = new XMLHttpRequest(); //# Modern
	} catch(ex) {
		try {
			x = new ActiveXObject("Msxml2.XMLHTTP"); //# IE 6
		} catch(ex2) {
		}
	}
	if(!x)
		return "Can't create XMLHttpRequest object";
	x.onreadystatechange = function() {
		try {
			var status = x.status;
		} catch(ex) {
			status = false;
		}
		if(x.readyState == 4 && callback && (status !== undefined)) {
			if([0, 200, 201, 204, 207].contains(status))
				callback(true,params,x.responseText,url,x);
			else
				callback(false,params,null,url,x);
			x.onreadystatechange = function(){};
			x = null;
		}
	};
	if(window.Components && window.netscape && window.netscape.security && document.location.protocol.indexOf("http") == -1)
		window.netscape.security.PrivilegeManager.enablePrivilege("UniversalBrowserRead");
	try {
		if(!allowCache)
			url = url + (url.indexOf("?") < 0 ? "?" : "&") + "nocache=" + Math.random();
		x.open(type,url,true,username,password);
		if(data)
			x.setRequestHeader("Content-Type", contentType || "application/x-www-form-urlencoded");
		if(x.overrideMimeType)
			x.setRequestHeader("Connection", "close");
		if(headers) {
			for(var n in headers)
				x.setRequestHeader(n,headers[n]);
		}
		x.setRequestHeader("X-Requested-With", "TiddlyWiki " + formatVersion());
		x.send(data);
	} catch(ex) {
		return exceptionText(ex);
	}
	return x;
}

// included for compatibility
function getXMLHttpRequest()
{
	try {
		var x = new XMLHttpRequest(); // Modern
	} catch(ex) {
		try {
			x = new ActiveXObject("Msxml2.XMLHTTP"); // IE 6
		} catch (ex2) {
			return null;
		}
	}
	return x;
}

// included for compatibility
function doHttp(type,url,data,contentType,username,password,callback,params,headers,allowCache)
{
	return httpReq(type,url,callback,params,headers,data,contentType,username,password,allowCache);
}

//--
//-- TiddlyWiki-specific utility functions
//--

function formatVersion(v)
{
	v = v || version;
	return v.major + "." + v.minor + "." + v.revision + (v.beta ? " (beta " + v.beta + ")" : "");
}

function compareVersions(v1,v2)
{
	var a = ["major","minor","revision"];
	for(var i = 0; i<a.length; i++) {
		var x1 = v1[a[i]] || 0;
		var x2 = v2[a[i]] || 0;
		if(x1<x2)
			return 1;
		if(x1>x2)
			return -1;
	}
	x1 = v1.beta || 9999;
	x2 = v2.beta || 9999;
	if(x1<x2)
		return 1;
	return x1 > x2 ? -1 : 0;
}

function createTiddlyButton(parent,text,tooltip,action,className,id,accessKey,attribs)
{
	var btn = document.createElement("a");
	if(action) {
		btn.onclick = action;
		btn.setAttribute("href","javascript:;");
	}
	if(tooltip)
		btn.setAttribute("title",tooltip);
	if(text)
		btn.appendChild(document.createTextNode(text));
	btn.className = className || "button";
	if(id)
		btn.id = id;
	if(attribs) {
		for(var i in attribs) {
			btn.setAttribute(i,attribs[i]);
		}
	}
	if(parent)
		parent.appendChild(btn);
	if(accessKey)
		btn.setAttribute("accessKey",accessKey);
	return btn;
}

function createTiddlyLink(place,title,includeText,className,isStatic,linkedFromTiddler,noToggle)
{
	var text = includeText ? title : null;
	var i = getTiddlyLinkInfo(title,className);
	var btn = isStatic ? createExternalLink(place,store.getTiddlerText("SiteUrl",null) + "#" + title) : createTiddlyButton(place,text,i.subTitle,onClickTiddlerLink,i.classes);
	if(isStatic)
		btn.className += ' ' + className;
	btn.setAttribute("refresh","link");
	btn.setAttribute("tiddlyLink",title);
	if(noToggle)
		btn.setAttribute("noToggle","true");
	if(linkedFromTiddler) {
		var fields = linkedFromTiddler.getInheritedFields();
		if(fields)
			btn.setAttribute("tiddlyFields",fields);
	}
	return btn;
}

function refreshTiddlyLink(e,title)
{
	var i = getTiddlyLinkInfo(title,e.className);
	e.className = i.classes;
	e.title = i.subTitle;
}

function getTiddlyLinkInfo(title,currClasses)
{
	var classes = currClasses ? currClasses.split(" ") : [];
	classes.pushUnique("tiddlyLink");
	var tiddler = store.fetchTiddler(title);
	var subTitle;
	if(tiddler) {
		subTitle = tiddler.getSubtitle();
		classes.pushUnique("tiddlyLinkExisting");
		classes.remove("tiddlyLinkNonExisting");
		classes.remove("shadow");
	} else {
		classes.remove("tiddlyLinkExisting");
		classes.pushUnique("tiddlyLinkNonExisting");
		if(store.isShadowTiddler(title)) {
			subTitle = config.messages.shadowedTiddlerToolTip.format([title]);
			classes.pushUnique("shadow");
		} else {
			subTitle = config.messages.undefinedTiddlerToolTip.format([title]);
			classes.remove("shadow");
		}
	}
	if(typeof config.annotations[title]=="string")
		subTitle = config.annotations[title];
	return {classes: classes.join(" "),subTitle: subTitle};
}

function createExternalLink(place,url)
{
	var link = document.createElement("a");
	link.className = "externalLink";
	link.href = url;
	link.title = config.messages.externalLinkTooltip.format([url]);
	if(config.options.chkOpenInNewWindow)
		link.target = "_blank";
	place.appendChild(link);
	return link;
}

// Event handler for clicking on a tiddly link
function onClickTiddlerLink(ev)
{
	var e = ev || window.event;
	var target = resolveTarget(e);
	var link = target;
	var title = null;
	var fields = null;
	var noToggle = null;
	do {
		title = link.getAttribute("tiddlyLink");
		fields = link.getAttribute("tiddlyFields");
		noToggle = link.getAttribute("noToggle");
		link = link.parentNode;
	} while(title == null && link != null);
	if(!store.isShadowTiddler(title)) {
		var f = fields ? fields.decodeHashMap() : {};
		fields = String.encodeHashMap(merge(f,config.defaultCustomFields,true));
	}
	if(title) {
		var toggling = e.metaKey || e.ctrlKey;
		if(config.options.chkToggleLinks)
			toggling = !toggling;
		if(noToggle)
			toggling = false;
		if(store.getTiddler(title))
			fields = null;
		story.displayTiddler(target,title,null,true,null,fields,toggling);
	}
	clearMessage();
	return false;
}

// Create a button for a tag with a popup listing all the tiddlers that it tags
function createTagButton(place,tag,excludeTiddler,title,tooltip)
{
	var btn = createTiddlyButton(place,title||tag,(tooltip||config.views.wikified.tag.tooltip).format([tag]),onClickTag);
	btn.setAttribute("tag",tag);
	if(excludeTiddler)
		btn.setAttribute("tiddler",excludeTiddler);
	return btn;
}

// Event handler for clicking on a tiddler tag
function onClickTag(ev)
{
	var e = ev || window.event;
	var popup = Popup.create(this);
	var tag = this.getAttribute("tag");
	var title = this.getAttribute("tiddler");
	if(popup && tag) {
		var tagged = store.getTaggedTiddlers(tag);
		var titles = [];
		var li,r;
		for(r=0;r<tagged.length;r++) {
			if(tagged[r].title != title)
				titles.push(tagged[r].title);
		}
		var lingo = config.views.wikified.tag;
		if(titles.length > 0) {
			var openAll = createTiddlyButton(createTiddlyElement(popup,"li"),lingo.openAllText.format([tag]),lingo.openAllTooltip,onClickTagOpenAll);
			openAll.setAttribute("tag",tag);
			createTiddlyElement(createTiddlyElement(popup,"li",null,"listBreak"),"div");
			for(r=0; r<titles.length; r++) {
				createTiddlyLink(createTiddlyElement(popup,"li"),titles[r],true);
			}
		} else {
			createTiddlyText(createTiddlyElement(popup,"li",null,"disabled"),lingo.popupNone.format([tag]));
		}
		createTiddlyElement(createTiddlyElement(popup,"li",null,"listBreak"),"div");
		var h = createTiddlyLink(createTiddlyElement(popup,"li"),tag,false);
		createTiddlyText(h,lingo.openTag.format([tag]));
	}
	Popup.show();
	e.cancelBubble = true;
	if(e.stopPropagation) e.stopPropagation();
	return false;
}

// Event handler for 'open all' on a tiddler popup
function onClickTagOpenAll(ev)
{
	var tiddlers = store.getTaggedTiddlers(this.getAttribute("tag"));
	story.displayTiddlers(this,tiddlers);
	return false;
}

function onClickError(ev)
{
	var e = ev || window.event;
	var popup = Popup.create(this);
	var lines = this.getAttribute("errorText").split("\n");
	for(var t=0; t<lines.length; t++)
		createTiddlyElement(popup,"li",null,null,lines[t]);
	Popup.show();
	e.cancelBubble = true;
	if(e.stopPropagation) e.stopPropagation();
	return false;
}

function createTiddlyDropDown(place,onchange,options,defaultValue)
{
	var sel = createTiddlyElement(place,"select");
	sel.onchange = onchange;
	for(var t=0; t<options.length; t++) {
		var e = createTiddlyElement(sel,"option",null,null,options[t].caption);
		e.value = options[t].name;
		if(options[t].name == defaultValue)
			e.selected = true;
	}
	return sel;
}

function createTiddlyPopup(place,caption,tooltip,tiddler)
{
	if(tiddler.text) {
		createTiddlyLink(place,caption,true);
		var btn = createTiddlyButton(place,glyph("downArrow"),tooltip,onClickTiddlyPopup,"tiddlerPopupButton");
		btn.tiddler = tiddler;
	} else {
		createTiddlyText(place,caption);
	}
}

function onClickTiddlyPopup(ev)
{
	var e = ev || window.event;
	var tiddler = this.tiddler;
	if(tiddler.text) {
		var popup = Popup.create(this,"div","popupTiddler");
		wikify(tiddler.text,popup,null,tiddler);
		Popup.show();
	}
	if(e) e.cancelBubble = true;
	if(e && e.stopPropagation) e.stopPropagation();
	return false;
}

function createTiddlyError(place,title,text)
{
	var btn = createTiddlyButton(place,title,null,onClickError,"errorButton");
	if(text) btn.setAttribute("errorText",text);
}

function merge(dst,src,preserveExisting)
{
	for(var i in src) {
		if(!preserveExisting || dst[i] === undefined)
			dst[i] = src[i];
	}
	return dst;
}

// Returns a string containing the description of an exception, optionally prepended by a message
function exceptionText(e,message)
{
	var s = e.description || e.toString();
	return message ? "%0:\n%1".format([message,s]) : s;
}

// Displays an alert of an exception description with optional message
function showException(e,message)
{
	alert(exceptionText(e,message));
}

function alertAndThrow(m)
{
	alert(m);
	throw(m);
}

function glyph(name)
{
	var g = config.glyphs;
	var b = g.currBrowser;
	if(b == null) {
		b = 0;
		while(!g.browsers[b]() && b < g.browsers.length-1)
			b++;
		g.currBrowser = b;
	}
	if(!g.codes[name])
		return "";
	return g.codes[name][b];
}

if(!window.console) {
	console = {log:function(message) {displayMessage(message);}};
}

//-
//- Animation engine
//-

function Animator()
{
	this.running = 0; // Incremented at start of each animation, decremented afterwards. If zero, the interval timer is disabled
	this.timerID = 0; // ID of the timer used for animating
	this.animations = []; // List of animations in progress
	return this;
}

// Start animation engine
Animator.prototype.startAnimating = function() //# Variable number of arguments
{
	for(var t=0; t<arguments.length; t++)
		this.animations.push(arguments[t]);
	if(this.running == 0) {
		var me = this;
		this.timerID = window.setInterval(function() {me.doAnimate(me);},10);
	}
	this.running += arguments.length;
};

// Perform an animation engine tick, calling each of the known animation modules
Animator.prototype.doAnimate = function(me)
{
	var a = 0;
	while(a < me.animations.length) {
		var animation = me.animations[a];
		if(animation.tick()) {
			a++;
		} else {
			me.animations.splice(a,1);
			if(--me.running == 0)
				window.clearInterval(me.timerID);
		}
	}
};

Animator.slowInSlowOut = function(progress)
{
	return(1-((Math.cos(progress * Math.PI)+1)/2));
};

//--
//-- Morpher animation
//--

// Animate a set of properties of an element
function Morpher(element,duration,properties,callback)
{
	this.element = element;
	this.duration = duration;
	this.properties = properties;
	this.startTime = new Date();
	this.endTime = Number(this.startTime) + duration;
	this.callback = callback;
	this.tick();
	return this;
}

Morpher.prototype.assignStyle = function(element,style,value)
{
	switch(style) {
	case "-tw-vertScroll":
		window.scrollTo(findScrollX(),value);
		break;
	case "-tw-horizScroll":
		window.scrollTo(value,findScrollY());
		break;
	default:
		element.style[style] = value;
		break;
	}
};

Morpher.prototype.stop = function()
{
	for(var t=0; t<this.properties.length; t++) {
		var p = this.properties[t];
		if(p.atEnd !== undefined) {
			this.assignStyle(this.element,p.style,p.atEnd);
		}
	}
	if(this.callback)
		this.callback(this.element,this.properties);
};

Morpher.prototype.tick = function()
{
	var currTime = Number(new Date());
	var progress = Animator.slowInSlowOut(Math.min(1,(currTime-this.startTime)/this.duration));
	for(var t=0; t<this.properties.length; t++) {
		var p = this.properties[t];
		if(p.start !== undefined && p.end !== undefined) {
			var template = p.template || "%0";
			switch(p.format) {
			case undefined:
			case "style":
				var v = p.start + (p.end-p.start) * progress;
				this.assignStyle(this.element,p.style,template.format([v]));
				break;
			case "color":
				break;
			}
		}
	}
	if(currTime >= this.endTime) {
		this.stop();
		return false;
	}
	return true;
};

//--
//-- Zoomer animation
//--

function Zoomer(text,startElement,targetElement,unused)
{
	var e = createTiddlyElement(document.body,"div",null,"zoomer");
	createTiddlyElement(e,"div",null,null,text);
	var winWidth = findWindowWidth();
	var winHeight = findWindowHeight();
	var p = [
		{style: 'left', start: findPosX(startElement), end: findPosX(targetElement), template: '%0px'},
		{style: 'top', start: findPosY(startElement), end: findPosY(targetElement), template: '%0px'},
		{style: 'width', start: Math.min(startElement.scrollWidth,winWidth), end: Math.min(targetElement.scrollWidth,winWidth), template: '%0px', atEnd: 'auto'},
		{style: 'height', start: Math.min(startElement.scrollHeight,winHeight), end: Math.min(targetElement.scrollHeight,winHeight), template: '%0px', atEnd: 'auto'},
		{style: 'fontSize', start: 8, end: 24, template: '%0pt'}
	];
	var c = function(element,properties) {removeNode(element);};
	return new Morpher(e,config.animDuration,p,c);
}

//--
//-- Scroller animation
//--

function Scroller(targetElement)
{
	var p = [{style: '-tw-vertScroll', start: findScrollY(), end: ensureVisible(targetElement)}];
	return new Morpher(targetElement,config.animDuration,p);
}

//--
//-- Slider animation
//--

// deleteMode - "none", "all" [delete target element and it's children], [only] "children" [but not the target element]
function Slider(element,opening,unused,deleteMode)
{
	element.style.overflow = 'hidden';
	if(opening)
		element.style.height = '0px'; // Resolves a Firefox flashing bug
	element.style.display = 'block';
	var left = findPosX(element);
	var width = element.scrollWidth;
	var height = element.scrollHeight;
	var winWidth = findWindowWidth();
	var p = [];
	var c = null;
	if(opening) {
		p.push({style: 'height', start: 0, end: height, template: '%0px', atEnd: 'auto'});
		p.push({style: 'opacity', start: 0, end: 1, template: '%0'});
		p.push({style: 'filter', start: 0, end: 100, template: 'alpha(opacity:%0)'});
	} else {
		p.push({style: 'height', start: height, end: 0, template: '%0px'});
		p.push({style: 'display', atEnd: 'none'});
		p.push({style: 'opacity', start: 1, end: 0, template: '%0'});
		p.push({style: 'filter', start: 100, end: 0, template: 'alpha(opacity:%0)'});
		switch(deleteMode) {
		case "all":
			c = function(element,properties) {removeNode(element);};
			break;
		case "children":
			c = function(element,properties) {removeChildren(element);};
			break;
		}
	}
	return new Morpher(element,config.animDuration,p,c);
}

//--
//-- Popup menu
//--

var Popup = {
	stack: [] // Array of objects with members root: and popup:
	};

Popup.create = function(root,elem,className)
{
	var stackPosition = this.find(root,"popup");
	Popup.remove(stackPosition+1);
	var popup = createTiddlyElement(document.body,elem || "ol","popup",className || "popup");
	popup.stackPosition = stackPosition;
	Popup.stack.push({root: root, popup: popup});
	return popup;
};

Popup.onDocumentClick = function(ev)
{
	var e = ev || window.event;
	if(e.eventPhase == undefined)
		Popup.remove();
	else if(e.eventPhase == Event.BUBBLING_PHASE || e.eventPhase == Event.AT_TARGET)
		Popup.remove();
	return true;
};

Popup.show = function(valign,halign,offset)
{
	var curr = Popup.stack[Popup.stack.length-1];
	this.place(curr.root,curr.popup,valign,halign,offset);
	addClass(curr.root,"highlight");
	if(config.options.chkAnimate && anim && typeof Scroller == "function")
		anim.startAnimating(new Scroller(curr.popup));
	else
		window.scrollTo(0,ensureVisible(curr.popup));
};

Popup.place = function(root,popup,valign,halign,offset)
{
	if(!offset)
		var offset = {x:0,y:0};
	if(popup.stackPosition >= 0 && !valign && !halign) {
		offset.x = offset.x + root.offsetWidth;
	} else {
		offset.x = (halign == 'right') ? offset.x + root.offsetWidth : offset.x;
		offset.y = (valign == 'top') ? offset.y : offset.y + root.offsetHeight;
	}
	var rootLeft = findPosX(root);
	var rootTop = findPosY(root);
	var popupLeft = rootLeft + offset.x;
	var popupTop = rootTop + offset.y;
	var winWidth = findWindowWidth();
	if(popup.offsetWidth > winWidth*0.75)
		popup.style.width = winWidth*0.75 + "px";
	var popupWidth = popup.offsetWidth;
	var scrollWidth = winWidth - document.body.offsetWidth;
	if(popupLeft + popupWidth > winWidth - scrollWidth - 1) {
		if(halign == 'right')
			popupLeft = popupLeft - root.offsetWidth - popupWidth;
		else
			popupLeft = winWidth - popupWidth - scrollWidth - 1;
	}
	popup.style.left = popupLeft + "px";
	popup.style.top = popupTop + "px";
	popup.style.display = "block";
};

Popup.find = function(e)
{
	var pos = -1;
	for (var t=this.stack.length-1; t>=0; t--) {
		if(isDescendant(e,this.stack[t].popup))
			pos = t;
	}
	return pos;
};

Popup.remove = function(pos)
{
	if(!pos) var pos = 0;
	if(Popup.stack.length > pos) {
		Popup.removeFrom(pos);
	}
};

Popup.removeFrom = function(from)
{
	for(var t=Popup.stack.length-1; t>=from; t--) {
		var p = Popup.stack[t];
		removeClass(p.root,"highlight");
		removeNode(p.popup);
	}
	Popup.stack = Popup.stack.slice(0,from);
};

//--
//-- Wizard support
//--

function Wizard(elem)
{
	if(elem) {
		this.formElem = findRelated(elem,"wizard","className");
		this.bodyElem = findRelated(this.formElem.firstChild,"wizardBody","className","nextSibling");
		this.footElem = findRelated(this.formElem.firstChild,"wizardFooter","className","nextSibling");
	} else {
		this.formElem = null;
		this.bodyElem = null;
		this.footElem = null;
	}
}

Wizard.prototype.setValue = function(name,value)
{
	if(this.formElem)
		this.formElem[name] = value;
};

Wizard.prototype.getValue = function(name)
{
	return this.formElem ? this.formElem[name] : null;
};

Wizard.prototype.createWizard = function(place,title)
{
	this.formElem = createTiddlyElement(place,"form",null,"wizard");
	createTiddlyElement(this.formElem,"h1",null,null,title);
	this.bodyElem = createTiddlyElement(this.formElem,"div",null,"wizardBody");
	this.footElem = createTiddlyElement(this.formElem,"div",null,"wizardFooter");
};

Wizard.prototype.clear = function()
{
	removeChildren(this.bodyElem);
};

Wizard.prototype.setButtons = function(buttonInfo,status)
{
	removeChildren(this.footElem);
	for(var t=0; t<buttonInfo.length; t++) {
		createTiddlyButton(this.footElem,buttonInfo[t].caption,buttonInfo[t].tooltip,buttonInfo[t].onClick);
		insertSpacer(this.footElem);
		}
	if(typeof status == "string") {
		createTiddlyElement(this.footElem,"span",null,"status",status);
	}
};

Wizard.prototype.addStep = function(stepTitle,html)
{
	removeChildren(this.bodyElem);
	var w = createTiddlyElement(this.bodyElem,"div");
	createTiddlyElement(w,"h2",null,null,stepTitle);
	var step = createTiddlyElement(w,"div",null,"wizardStep");
	step.innerHTML = html;
	applyHtmlMacros(step,tiddler);
};

Wizard.prototype.getElement = function(name)
{
	return this.formElem.elements[name];
};

//--
//-- ListView gadget
//--

var ListView = {};

// Create a listview
ListView.create = function(place,listObject,listTemplate,callback,className)
{
	var table = createTiddlyElement(place,"table",null,className || "listView twtable");
	var thead = createTiddlyElement(table,"thead");
	var r = createTiddlyElement(thead,"tr");
	for(var t=0; t<listTemplate.columns.length; t++) {
		var columnTemplate = listTemplate.columns[t];
		var c = createTiddlyElement(r,"th");
		var colType = ListView.columnTypes[columnTemplate.type];
		if(colType && colType.createHeader) {
			colType.createHeader(c,columnTemplate,t);
			if(columnTemplate.className)
				addClass(c,columnTemplate.className);
		}
	}
	var tbody = createTiddlyElement(table,"tbody");
	for(var rc=0; rc<listObject.length; rc++) {
		var rowObject = listObject[rc];
		r = createTiddlyElement(tbody,"tr");
		for(c=0; c<listTemplate.rowClasses.length; c++) {
			if(rowObject[listTemplate.rowClasses[c].field])
				addClass(r,listTemplate.rowClasses[c].className);
		}
		rowObject.rowElement = r;
		rowObject.colElements = {};
		for(var cc=0; cc<listTemplate.columns.length; cc++) {
			c = createTiddlyElement(r,"td");
			columnTemplate = listTemplate.columns[cc];
			var field = columnTemplate.field;
			colType = ListView.columnTypes[columnTemplate.type];
			if(colType && colType.createItem) {
				colType.createItem(c,rowObject,field,columnTemplate,cc,rc);
				if(columnTemplate.className)
					addClass(c,columnTemplate.className);
			}
			rowObject.colElements[field] = c;
		}
	}
	if(callback && listTemplate.actions)
		createTiddlyDropDown(place,ListView.getCommandHandler(callback),listTemplate.actions);
	if(callback && listTemplate.buttons) {
		for(t=0; t<listTemplate.buttons.length; t++) {
			var a = listTemplate.buttons[t];
			if(a && a.name != "")
				createTiddlyButton(place,a.caption,null,ListView.getCommandHandler(callback,a.name,a.allowEmptySelection));
		}
	}
	return table;
};

ListView.getCommandHandler = function(callback,name,allowEmptySelection)
{
	return function(e) {
		var view = findRelated(this,"TABLE",null,"previousSibling");
		var tiddlers = [];
		ListView.forEachSelector(view,function(e,rowName) {
					if(e.checked)
						tiddlers.push(rowName);
					});
		if(tiddlers.length == 0 && !allowEmptySelection) {
			alert(config.messages.nothingSelected);
		} else {
			if(this.nodeName.toLowerCase() == "select") {
				callback(view,this.value,tiddlers);
				this.selectedIndex = 0;
			} else {
				callback(view,name,tiddlers);
			}
		}
	};
};

// Invoke a callback for each selector checkbox in the listview
ListView.forEachSelector = function(view,callback)
{
	var checkboxes = view.getElementsByTagName("input");
	var hadOne = false;
	for(var t=0; t<checkboxes.length; t++) {
		var cb = checkboxes[t];
		if(cb.getAttribute("type") == "checkbox") {
			var rn = cb.getAttribute("rowName");
			if(rn) {
				callback(cb,rn);
				hadOne = true;
			}
		}
	}
	return hadOne;
};

ListView.getSelectedRows = function(view)
{
	var rowNames = [];
	ListView.forEachSelector(view,function(e,rowName) {
				if(e.checked)
					rowNames.push(rowName);
				});
	return rowNames;
};

ListView.columnTypes = {};

ListView.columnTypes.String = {
	createHeader: function(place,columnTemplate,col)
		{
			createTiddlyText(place,columnTemplate.title);
		},
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var v = listObject[field];
			if(v != undefined)
				createTiddlyText(place,v);
		}
};

ListView.columnTypes.WikiText = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var v = listObject[field];
			if(v != undefined)
				wikify(v,place,null,null);
		}
};

ListView.columnTypes.Tiddler = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var v = listObject[field];
			if(v != undefined && v.title)
				createTiddlyPopup(place,v.title,config.messages.listView.tiddlerTooltip,v);
		}
};

ListView.columnTypes.Size = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var v = listObject[field];
			if(v != undefined) {
				var t = 0;
				while(t<config.messages.sizeTemplates.length-1 && v<config.messages.sizeTemplates[t].unit)
					t++;
				createTiddlyText(place,config.messages.sizeTemplates[t].template.format([Math.round(v/config.messages.sizeTemplates[t].unit)]));
			}
		}
};

ListView.columnTypes.Link = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var v = listObject[field];
			var c = columnTemplate.text;
			if(v != undefined)
				createTiddlyText(createExternalLink(place,v),c || v);
		}
};

ListView.columnTypes.Date = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var v = listObject[field];
			if(v != undefined)
				createTiddlyText(place,v.formatString(columnTemplate.dateFormat));
		}
};

ListView.columnTypes.StringList = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var v = listObject[field];
			if(v != undefined) {
				for(var t=0; t<v.length; t++) {
					createTiddlyText(place,v[t]);
					createTiddlyElement(place,"br");
				}
			}
		}
};

ListView.columnTypes.Selector = {
	createHeader: function(place,columnTemplate,col)
		{
			createTiddlyCheckbox(place,null,false,this.onHeaderChange);
		},
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var e = createTiddlyCheckbox(place,null,listObject[field],null);
			e.setAttribute("rowName",listObject[columnTemplate.rowName]);
		},
	onHeaderChange: function(e)
		{
			var state = this.checked;
			var view = findRelated(this,"TABLE");
			if(!view)
				return;
			ListView.forEachSelector(view,function(e,rowName) {
								e.checked = state;
							});
		}
};

ListView.columnTypes.Tags = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var tags = listObject[field];
			createTiddlyText(place,String.encodeTiddlyLinkList(tags));
		}
};

ListView.columnTypes.Boolean = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			if(listObject[field] == true)
				createTiddlyText(place,columnTemplate.trueText);
			if(listObject[field] == false)
				createTiddlyText(place,columnTemplate.falseText);
		}
};

ListView.columnTypes.TagCheckbox = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var e = createTiddlyCheckbox(place,null,listObject[field],this.onChange);
			e.setAttribute("tiddler",listObject.title);
			e.setAttribute("tag",columnTemplate.tag);
		},
	onChange : function(e)
		{
			var tag = this.getAttribute("tag");
			var tiddler = this.getAttribute("tiddler");
			store.setTiddlerTag(tiddler,this.checked,tag);
		}
};

ListView.columnTypes.TiddlerLink = {
	createHeader: ListView.columnTypes.String.createHeader,
	createItem: function(place,listObject,field,columnTemplate,col,row)
		{
			var v = listObject[field];
			if(v != undefined) {
				var link = createTiddlyLink(place,listObject[columnTemplate.tiddlerLink],false,null);
				createTiddlyText(link,listObject[field]);
			}
		}
};

//--
//-- Augmented methods for the JavaScript Number(), Array(), String() and Date() objects
//--

// Clamp a number to a range
Number.prototype.clamp = function(min,max)
{
	var c = this;
	if(c < min)
		c = min;
	if(c > max)
		c = max;
	return c;
};

// Add indexOf function if browser does not support it
if(!Array.indexOf) {
Array.prototype.indexOf = function(item,from)
{
	if(!from)
		from = 0;
	for(var i=from; i<this.length; i++) {
		if(this[i] === item)
			return i;
	}
	return -1;
};}

// Find an entry in a given field of the members of an array
Array.prototype.findByField = function(field,value)
{
	for(var t=0; t<this.length; t++) {
		if(this[t][field] == value)
			return t;
	}
	return null;
};

// Return whether an entry exists in an array
Array.prototype.contains = function(item)
{
	return this.indexOf(item) != -1;
};

// Adds, removes or toggles a particular value within an array
//  value - value to add
//  mode - +1 to add value, -1 to remove value, 0 to toggle it
Array.prototype.setItem = function(value,mode)
{
	var p = this.indexOf(value);
	if(mode == 0)
		mode = (p == -1) ? +1 : -1;
	if(mode == +1) {
		if(p == -1)
			this.push(value);
	} else if(mode == -1) {
		if(p != -1)
			this.splice(p,1);
	}
};

// Return whether one of a list of values exists in an array
Array.prototype.containsAny = function(items)
{
	for(var i=0; i<items.length; i++) {
		if(this.indexOf(items[i]) != -1)
			return true;
	}
	return false;
};

// Return whether all of a list of values exists in an array
Array.prototype.containsAll = function(items)
{
	for(var i = 0; i<items.length; i++) {
		if(this.indexOf(items[i]) == -1)
			return false;
	}
	return true;
};

// Push a new value into an array only if it is not already present in the array. If the optional unique parameter is false, it reverts to a normal push
Array.prototype.pushUnique = function(item,unique)
{
	if(unique === false) {
		this.push(item);
	} else {
		if(this.indexOf(item) == -1)
			this.push(item);
	}
};

Array.prototype.remove = function(item)
{
	var p = this.indexOf(item);
	if(p != -1)
		this.splice(p,1);
};

if(!Array.prototype.map) {
Array.prototype.map = function(fn,thisObj)
{
	var scope = thisObj || window;
	var a = [];
	for(var i=0, j=this.length; i < j; ++i) {
		a.push(fn.call(scope,this[i],i,this));
	}
	return a;
};}

// Get characters from the right end of a string
String.prototype.right = function(n)
{
	return n < this.length ? this.slice(this.length-n) : this;
};

// Trim whitespace from both ends of a string
String.prototype.trim = function()
{
	return this.replace(/^\s*|\s*$/g,"");
};

// Convert a string from a CSS style property name to a JavaScript style name ("background-color" -> "backgroundColor")
String.prototype.unDash = function()
{
	var s = this.split("-");
	if(s.length > 1) {
		for(var t=1; t<s.length; t++)
			s[t] = s[t].substr(0,1).toUpperCase() + s[t].substr(1);
	}
	return s.join("");
};

// Substitute substrings from an array into a format string that includes '%1'-type specifiers
String.prototype.format = function(substrings)
{
	var subRegExp = /(?:%(\d+))/mg;
	var currPos = 0;
	var r = [];
	do {
		var match = subRegExp.exec(this);
		if(match && match[1]) {
			if(match.index > currPos)
				r.push(this.substring(currPos,match.index));
			r.push(substrings[parseInt(match[1])]);
			currPos = subRegExp.lastIndex;
		}
	} while(match);
	if(currPos < this.length)
		r.push(this.substring(currPos,this.length));
	return r.join("");
};

// Escape any special RegExp characters with that character preceded by a backslash
String.prototype.escapeRegExp = function()
{
	var s = "\\^$*+?()=!|,{}[].";
	var c = this;
	for(var t=0; t<s.length; t++)
		c = c.replace(new RegExp("\\" + s.substr(t,1),"g"),"\\" + s.substr(t,1));
	return c;
};

// Convert "\" to "\s", newlines to "\n" (and remove carriage returns)
String.prototype.escapeLineBreaks = function()
{
	return this.replace(/\\/mg,"\\s").replace(/\n/mg,"\\n").replace(/\r/mg,"");
};

// Convert "\n" to newlines, "\b" to " ", "\s" to "\" (and remove carriage returns)
String.prototype.unescapeLineBreaks = function()
{
	return this.replace(/\\n/mg,"\n").replace(/\\b/mg," ").replace(/\\s/mg,"\\").replace(/\r/mg,"");
};

// Convert & to "&amp;", < to "&lt;", > to "&gt;" and " to "&quot;"
String.prototype.htmlEncode = function()
{
	return this.replace(/&/mg,"&amp;").replace(/</mg,"&lt;").replace(/>/mg,"&gt;").replace(/\"/mg,"&quot;");
};

// Convert "&amp;" to &, "&lt;" to <, "&gt;" to > and "&quot;" to "
String.prototype.htmlDecode = function()
{
	return this.replace(/&lt;/mg,"<").replace(/&gt;/mg,">").replace(/&quot;/mg,"\"").replace(/&amp;/mg,"&");
};

// Convert a string to it's JSON representation by encoding control characters, double quotes and backslash. See json.org
String.prototype.toJSONString = function()
{
	var m = {
		'\b': '\\b',
		'\f': '\\f',
		'\n': '\\n',
		'\r': '\\r',
		'\t': '\\t',
		'"' : '\\"',
		'\\': '\\\\'
		};
	var replaceFn = function(a,b) {
		var c = m[b];
		if(c)
			return c;
		c = b.charCodeAt();
		return '\\u00' + Math.floor(c / 16).toString(16) + (c % 16).toString(16);
		};
	if(/["\\\x00-\x1f]/.test(this))
		return '"' + this.replace(/([\x00-\x1f\\"])/g,replaceFn) + '"';
	return '"' + this + '"';
};

// Parse a space-separated string of name:value parameters
// The result is an array of objects:
//   result[0] = object with a member for each parameter name, value of that member being an array of values
//   result[1..n] = one object for each parameter, with 'name' and 'value' members
String.prototype.parseParams = function(defaultName,defaultValue,allowEval,noNames,cascadeDefaults)
{
	var parseToken = function(match,p) {
		var n;
		if(match[p]) // Double quoted
			n = match[p];
		else if(match[p+1]) // Single quoted
			n = match[p+1];
		else if(match[p+2]) // Double-square-bracket quoted
			n = match[p+2];
		else if(match[p+3]) // Double-brace quoted
			try {
				n = match[p+3];
				if(allowEval)
					n = window.eval(n);
			} catch(ex) {
				throw "Unable to evaluate {{" + match[p+3] + "}}: " + exceptionText(ex);
			}
		else if(match[p+4]) // Unquoted
			n = match[p+4];
		else if(match[p+5]) // empty quote
			n = "";
		return n;
	};
	var r = [{}];
	var dblQuote = "(?:\"((?:(?:\\\\\")|[^\"])+)\")";
	var sngQuote = "(?:'((?:(?:\\\\\')|[^'])+)')";
	var dblSquare = "(?:\\[\\[((?:\\s|\\S)*?)\\]\\])";
	var dblBrace = "(?:\\{\\{((?:\\s|\\S)*?)\\}\\})";
	var unQuoted = noNames ? "([^\"'\\s]\\S*)" : "([^\"':\\s][^\\s:]*)";
	var emptyQuote = "((?:\"\")|(?:''))";
	var skipSpace = "(?:\\s*)";
	var token = "(?:" + dblQuote + "|" + sngQuote + "|" + dblSquare + "|" + dblBrace + "|" + unQuoted + "|" + emptyQuote + ")";
	var re = noNames ? new RegExp(token,"mg") : new RegExp(skipSpace + token + skipSpace + "(?:(\\:)" + skipSpace + token + ")?","mg");
	var params = [];
	do {
		var match = re.exec(this);
		if(match) {
			var n = parseToken(match,1);
			if(noNames) {
				r.push({name:"",value:n});
			} else {
				var v = parseToken(match,8);
				if(v == null && defaultName) {
					v = n;
					n = defaultName;
				} else if(v == null && defaultValue) {
					v = defaultValue;
				}
				r.push({name:n,value:v});
				if(cascadeDefaults) {
					defaultName = n;
					defaultValue = v;
				}
			}
		}
	} while(match);
	// Summarise parameters into first element
	for(var t=1; t<r.length; t++) {
		if(r[0][r[t].name])
			r[0][r[t].name].push(r[t].value);
		else
			r[0][r[t].name] = [r[t].value];
	}
	return r;
};

// Process a string list of macro parameters into an array. Parameters can be quoted with "", '',
// [[]], {{ }} or left unquoted (and therefore space-separated). Double-braces {{}} results in
// an *evaluated* parameter: e.g. {{config.options.txtUserName}} results in the current user's name.
String.prototype.readMacroParams = function()
{
	var p = this.parseParams("list",null,true,true);
	var n = [];
	for(var t=1; t<p.length; t++)
		n.push(p[t].value);
	return n;
};

// Process a string list of unique tiddler names into an array. Tiddler names that have spaces in them must be [[bracketed]]
String.prototype.readBracketedList = function(unique)
{
	var p = this.parseParams("list",null,false,true);
	var n = [];
	for(var t=1; t<p.length; t++) {
		if(p[t].value)
			n.pushUnique(p[t].value,unique);
	}
	return n;
};

// Returns array with start and end index of chunk between given start and end marker, or undefined.
String.prototype.getChunkRange = function(start,end)
{
	var s = this.indexOf(start);
	if(s != -1) {
		s += start.length;
		var e = this.indexOf(end,s);
		if(e != -1)
			return [s,e];
	}
};

// Replace a chunk of a string given start and end markers
String.prototype.replaceChunk = function(start,end,sub)
{
	var r = this.getChunkRange(start,end);
	return r ? this.substring(0,r[0]) + sub + this.substring(r[1]) : this;
};

// Returns a chunk of a string between start and end markers, or undefined
String.prototype.getChunk = function(start,end)
{
	var r = this.getChunkRange(start,end);
	if(r)
		return this.substring(r[0],r[1]);
};


// Static method to bracket a string with double square brackets if it contains a space
String.encodeTiddlyLink = function(title)
{
	return title.indexOf(" ") == -1 ? title : "[[" + title + "]]";
};

// Static method to encodeTiddlyLink for every item in an array and join them with spaces
String.encodeTiddlyLinkList = function(list)
{
	if(list) {
		var results = [];
		for(var t=0; t<list.length; t++)
			results.push(String.encodeTiddlyLink(list[t]));
		return results.join(" ");
	} else {
		return "";
	}
};

// Convert a string as a sequence of name:"value" pairs into a hashmap
String.prototype.decodeHashMap = function()
{
	var fields = this.parseParams("anon","",false);
	var r = {};
	for(var t=1; t<fields.length; t++)
		r[fields[t].name] = fields[t].value;
	return r;
};

// Static method to encode a hashmap into a name:"value"... string
String.encodeHashMap = function(hashmap)
{
	var r = [];
	for(var t in hashmap)
		r.push(t + ':"' + hashmap[t] + '"');
	return r.join(" ");
};

// Static method to left-pad a string with 0s to a certain width
String.zeroPad = function(n,d)
{
	var s = n.toString();
	if(s.length < d)
		s = "000000000000000000000000000".substr(0,d-s.length) + s;
	return s;
};

String.prototype.startsWith = function(prefix)
{
	return !prefix || this.substring(0,prefix.length) == prefix;
};

// Returns the first value of the given named parameter.
function getParam(params,name,defaultValue)
{
	if(!params)
		return defaultValue;
	var p = params[0][name];
	return p ? p[0] : defaultValue;
}

// Returns the first value of the given boolean named parameter.
function getFlag(params,name,defaultValue)
{
	return !!getParam(params,name,defaultValue);
}

// Substitute date components into a string
Date.prototype.formatString = function(template)
{
	var t = template.replace(/0hh12/g,String.zeroPad(this.getHours12(),2));
	t = t.replace(/hh12/g,this.getHours12());
	t = t.replace(/0hh/g,String.zeroPad(this.getHours(),2));
	t = t.replace(/hh/g,this.getHours());
	t = t.replace(/mmm/g,config.messages.dates.shortMonths[this.getMonth()]);
	t = t.replace(/0mm/g,String.zeroPad(this.getMinutes(),2));
	t = t.replace(/mm/g,this.getMinutes());
	t = t.replace(/0ss/g,String.zeroPad(this.getSeconds(),2));
	t = t.replace(/ss/g,this.getSeconds());
	t = t.replace(/[ap]m/g,this.getAmPm().toLowerCase());
	t = t.replace(/[AP]M/g,this.getAmPm().toUpperCase());
	t = t.replace(/wYYYY/g,this.getYearForWeekNo());
	t = t.replace(/wYY/g,String.zeroPad(this.getYearForWeekNo()-2000,2));
	t = t.replace(/YYYY/g,this.getFullYear());
	t = t.replace(/YY/g,String.zeroPad(this.getFullYear()-2000,2));
	t = t.replace(/MMM/g,config.messages.dates.months[this.getMonth()]);
	t = t.replace(/0MM/g,String.zeroPad(this.getMonth()+1,2));
	t = t.replace(/MM/g,this.getMonth()+1);
	t = t.replace(/0WW/g,String.zeroPad(this.getWeek(),2));
	t = t.replace(/WW/g,this.getWeek());
	t = t.replace(/DDD/g,config.messages.dates.days[this.getDay()]);
	t = t.replace(/ddd/g,config.messages.dates.shortDays[this.getDay()]);
	t = t.replace(/0DD/g,String.zeroPad(this.getDate(),2));
	t = t.replace(/DDth/g,this.getDate()+this.daySuffix());
	t = t.replace(/DD/g,this.getDate());
	var tz = this.getTimezoneOffset();
	var atz = Math.abs(tz);
	t = t.replace(/TZD/g,(tz < 0 ? '+' : '-') + String.zeroPad(Math.floor(atz / 60),2) + ':' + String.zeroPad(atz % 60,2));
	t = t.replace(/\\/g,"");
	return t;
};

Date.prototype.getWeek = function()
{
	var dt = new Date(this.getTime());
	var d = dt.getDay();
	if(d==0) d=7;// JavaScript Sun=0, ISO Sun=7
	dt.setTime(dt.getTime()+(4-d)*86400000);// shift day to Thurs of same week to calculate weekNo
	var n = Math.floor((dt.getTime()-new Date(dt.getFullYear(),0,1)+3600000)/86400000);
	return Math.floor(n/7)+1;
};

Date.prototype.getYearForWeekNo = function()
{
	var dt = new Date(this.getTime());
	var d = dt.getDay();
	if(d==0) d=7;// JavaScript Sun=0, ISO Sun=7
	dt.setTime(dt.getTime()+(4-d)*86400000);// shift day to Thurs of same week
	return dt.getFullYear();
};

Date.prototype.getHours12 = function()
{
	var h = this.getHours();
	return h > 12 ? h-12 : ( h > 0 ? h : 12 );
};

Date.prototype.getAmPm = function()
{
	return this.getHours() >= 12 ? config.messages.dates.pm : config.messages.dates.am;
};

Date.prototype.daySuffix = function()
{
	return config.messages.dates.daySuffixes[this.getDate()-1];
};

// Convert a date to local YYYYMMDDHHMM string format
Date.prototype.convertToLocalYYYYMMDDHHMM = function()
{
	return this.getFullYear() + String.zeroPad(this.getMonth()+1,2) + String.zeroPad(this.getDate(),2) + String.zeroPad(this.getHours(),2) + String.zeroPad(this.getMinutes(),2);
};

// Convert a date to UTC YYYYMMDDHHMM string format
Date.prototype.convertToYYYYMMDDHHMM = function()
{
	return this.getUTCFullYear() + String.zeroPad(this.getUTCMonth()+1,2) + String.zeroPad(this.getUTCDate(),2) + String.zeroPad(this.getUTCHours(),2) + String.zeroPad(this.getUTCMinutes(),2);
};

// Convert a date to UTC YYYYMMDD.HHMMSSMMM string format
Date.prototype.convertToYYYYMMDDHHMMSSMMM = function()
{
	return this.getUTCFullYear() + String.zeroPad(this.getUTCMonth()+1,2) + String.zeroPad(this.getUTCDate(),2) + "." + String.zeroPad(this.getUTCHours(),2) + String.zeroPad(this.getUTCMinutes(),2) + String.zeroPad(this.getUTCSeconds(),2) + String.zeroPad(this.getUTCMilliseconds(),4);
};

// Static method to create a date from a UTC YYYYMMDDHHMM format string
Date.convertFromYYYYMMDDHHMM = function(d)
{
	var hh = d.substr(8,2) || "00";
	var mm = d.substr(10,2) || "00";
	return new Date(Date.UTC(parseInt(d.substr(0,4),10),
			parseInt(d.substr(4,2),10)-1,
			parseInt(d.substr(6,2),10),
			parseInt(hh,10),
			parseInt(mm,10),0,0));
};

//--
//-- Crypto functions and associated conversion routines
//--

// Crypto 'namespace'
function Crypto() {}

// Convert a string to an array of big-endian 32-bit words
Crypto.strToBe32s = function(str)
{
	var be=[];
	var len=Math.floor(str.length/4);
	var i, j;
	for(i=0, j=0; i<len; i++, j+=4) {
		be[i]=((str.charCodeAt(j)&0xff) << 24)|((str.charCodeAt(j+1)&0xff) << 16)|((str.charCodeAt(j+2)&0xff) << 8)|(str.charCodeAt(j+3)&0xff);
	}
	while(j<str.length) {
		be[j>>2] |= (str.charCodeAt(j)&0xff)<<(24-(j*8)%32);
		j++;
	}
	return be;
};

// Convert an array of big-endian 32-bit words to a string
Crypto.be32sToStr = function(be)
{
	var str='';
	for(var i=0;i<be.length*32;i+=8) {
		str += String.fromCharCode((be[i>>5]>>>(24-i%32)) & 0xff);
	}
	return str;
};

// Convert an array of big-endian 32-bit words to a hex string
Crypto.be32sToHex = function(be)
{
	var hex='0123456789ABCDEF';
	var str='';
	for(var i=0;i<be.length*4;i++) {
		str += hex.charAt((be[i>>2]>>((3-i%4)*8+4))&0xF) + hex.charAt((be[i>>2]>>((3-i%4)*8))&0xF);
	}
	return str;
};

// Return, in hex, the SHA-1 hash of a string
Crypto.hexSha1Str = function(str)
{
	return Crypto.be32sToHex(Crypto.sha1Str(str));
};

// Return the SHA-1 hash of a string
Crypto.sha1Str = function(str)
{
	return Crypto.sha1(Crypto.strToBe32s(str),str.length);
};

// Calculate the SHA-1 hash of an array of blen bytes of big-endian 32-bit words
Crypto.sha1 = function(x,blen)
{
	// Add 32-bit integers, wrapping at 32 bits
	function add32(a,b)
	{
		var lsw=(a&0xFFFF)+(b&0xFFFF);
		var msw=(a>>16)+(b>>16)+(lsw>>16);
		return (msw<<16)|(lsw&0xFFFF);
	}
	function AA(a,b,c,d,e)
	{
		b=(b>>>27)|(b<<5);
		var lsw=(a&0xFFFF)+(b&0xFFFF)+(c&0xFFFF)+(d&0xFFFF)+(e&0xFFFF);
		var msw=(a>>16)+(b>>16)+(c>>16)+(d>>16)+(e>>16)+(lsw>>16);
		return (msw<<16)|(lsw&0xFFFF);
	}
	function RR(w,j)
	{
		var n=w[j-3]^w[j-8]^w[j-14]^w[j-16];
		return (n>>>31)|(n<<1);
	}

	var len=blen*8;
	x[len>>5] |= 0x80 << (24-len%32);
	x[((len+64>>9)<<4)+15]=len;
	var w=new Array(80);

	var k1=0x5A827999;
	var k2=0x6ED9EBA1;
	var k3=0x8F1BBCDC;
	var k4=0xCA62C1D6;

	var h0=0x67452301;
	var h1=0xEFCDAB89;
	var h2=0x98BADCFE;
	var h3=0x10325476;
	var h4=0xC3D2E1F0;

	for(var i=0;i<x.length;i+=16) {
		var j=0;
		var t;
		var a=h0;
		var b=h1;
		var c=h2;
		var d=h3;
		var e=h4;
		while(j<16) {
			w[j]=x[i+j];
			t=AA(e,a,d^(b&(c^d)),w[j],k1);
			e=d; d=c; c=(b>>>2)|(b<<30); b=a; a=t; j++;
		}
		while(j<20) {
			w[j]=RR(w,j);
			t=AA(e,a,d^(b&(c^d)),w[j],k1);
			e=d; d=c; c=(b>>>2)|(b<<30); b=a; a=t; j++;
		}
		while(j<40) {
			w[j]=RR(w,j);
			t=AA(e,a,b^c^d,w[j],k2);
			e=d; d=c; c=(b>>>2)|(b<<30); b=a; a=t; j++;
		}
		while(j<60) {
			w[j]=RR(w,j);
			t=AA(e,a,(b&c)|(d&(b|c)),w[j],k3);
			e=d; d=c; c=(b>>>2)|(b<<30); b=a; a=t; j++;
		}
		while(j<80) {
			w[j]=RR(w,j);
			t=AA(e,a,b^c^d,w[j],k4);
			e=d; d=c; c=(b>>>2)|(b<<30); b=a; a=t; j++;
		}
		h0=add32(h0,a);
		h1=add32(h1,b);
		h2=add32(h2,c);
		h3=add32(h3,d);
		h4=add32(h4,e);
	}
	return [h0,h1,h2,h3,h4];
};

//--
//-- RGB colour object
//--

// Construct an RGB colour object from a '#rrggbb', '#rgb' or 'rgb(n,n,n)' string or from separate r,g,b values
function RGB(r,g,b)
{
	this.r = 0;
	this.g = 0;
	this.b = 0;
	if(typeof r == "string") {
		if(r.substr(0,1) == "#") {
			if(r.length == 7) {
				this.r = parseInt(r.substr(1,2),16)/255;
				this.g = parseInt(r.substr(3,2),16)/255;
				this.b = parseInt(r.substr(5,2),16)/255;
			} else {
				this.r = parseInt(r.substr(1,1),16)/15;
				this.g = parseInt(r.substr(2,1),16)/15;
				this.b = parseInt(r.substr(3,1),16)/15;
			}
		} else {
			var rgbPattern = /rgb\s*\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)/;
			var c = r.match(rgbPattern);
			if(c) {
				this.r = parseInt(c[1],10)/255;
				this.g = parseInt(c[2],10)/255;
				this.b = parseInt(c[3],10)/255;
			}
		}
	} else {
		this.r = r;
		this.g = g;
		this.b = b;
	}
	return this;
}

// Mixes this colour with another in a specified proportion
// c = other colour to mix
// f = 0..1 where 0 is this colour and 1 is the new colour
// Returns an RGB object
RGB.prototype.mix = function(c,f)
{
	return new RGB(this.r + (c.r-this.r) * f,this.g + (c.g-this.g) * f,this.b + (c.b-this.b) * f);
};

// Return an rgb colour as a #rrggbb format hex string
RGB.prototype.toString = function()
{
	return "#" + ("0" + Math.floor(this.r.clamp(0,1) * 255).toString(16)).right(2) +
				 ("0" + Math.floor(this.g.clamp(0,1) * 255).toString(16)).right(2) +
				 ("0" + Math.floor(this.b.clamp(0,1) * 255).toString(16)).right(2);
};

//--
//-- DOM utilities - many derived from www.quirksmode.org
//--

function drawGradient(place,horiz,locolors,hicolors)
{
	if(!hicolors)
		hicolors = locolors;
	for(var t=0; t<= 100; t+=2) {
		var bar = document.createElement("div");
		place.appendChild(bar);
		bar.style.position = "absolute";
		bar.style.left = horiz ? t + "%" : 0;
		bar.style.top = horiz ? 0 : t + "%";
		bar.style.width = horiz ? (101-t) + "%" : "100%";
		bar.style.height = horiz ? "100%" : (101-t) + "%";
		bar.style.zIndex = -1;
		var p = t/100*(locolors.length-1);
		bar.style.backgroundColor = hicolors[Math.floor(p)].mix(locolors[Math.ceil(p)],p-Math.floor(p)).toString();
	}
}

function createTiddlyText(parent,text)
{
	return parent.appendChild(document.createTextNode(text));
}

function createTiddlyCheckbox(parent,caption,checked,onChange)
{
	var cb = document.createElement("input");
	cb.setAttribute("type","checkbox");
	cb.onclick = onChange;
	parent.appendChild(cb);
	cb.checked = checked;
	cb.className = "chkOptionInput";
	if(caption)
		wikify(caption,parent);
	return cb;
}

function createTiddlyElement(parent,element,id,className,text,attribs)
{
	var e = document.createElement(element);
	if(className != null)
		e.className = className;
	if(id != null)
		e.setAttribute("id",id);
	if(text != null)
		e.appendChild(document.createTextNode(text));
	if(attribs) {
		for(var n in attribs) {
			e.setAttribute(n,attribs[n]);
		}
	}
	if(parent != null)
		parent.appendChild(e);
	return e;
}

function addEvent(obj,type,fn)
{
	if(obj.attachEvent) {
		obj['e'+type+fn] = fn;
		obj[type+fn] = function(){obj['e'+type+fn](window.event);};
		obj.attachEvent('on'+type,obj[type+fn]);
	} else {
		obj.addEventListener(type,fn,false);
	}
}

function removeEvent(obj,type,fn)
{
	if(obj.detachEvent) {
		obj.detachEvent('on'+type,obj[type+fn]);
		obj[type+fn] = null;
	} else {
		obj.removeEventListener(type,fn,false);
	}
}

function addClass(e,className)
{
	var currClass = e.className.split(" ");
	if(currClass.indexOf(className) == -1)
		e.className += " " + className;
}

function removeClass(e,className)
{
	var currClass = e.className.split(" ");
	var i = currClass.indexOf(className);
	while(i != -1) {
		currClass.splice(i,1);
		i = currClass.indexOf(className);
	}
	e.className = currClass.join(" ");
}

function hasClass(e,className)
{
	if(e.className && e.className.split(" ").indexOf(className) != -1) {
		return true;
	}
	return false;
}

// Find the closest relative with a given property value (property defaults to tagName, relative defaults to parentNode)
function findRelated(e,value,name,relative)
{
	name = name || "tagName";
	relative = relative || "parentNode";
	if(name == "className") {
		while(e && !hasClass(e,value)) {
			e = e[relative];
		}
	} else {
		while(e && e[name] != value) {
			e = e[relative];
		}
	}
	return e;
}

// Resolve the target object of an event
function resolveTarget(e)
{
	var obj;
	if(e.target)
		obj = e.target;
	else if(e.srcElement)
		obj = e.srcElement;
	if(obj.nodeType == 3) // defeat Safari bug
		obj = obj.parentNode;
	return obj;
}

// Prevent an event from bubbling
function stopEvent(e)
{
	var ev = e || window.event;
	ev.cancelBubble = true;
	if(ev.stopPropagation) ev.stopPropagation();
	return false;
}

// Return the content of an element as plain text with no formatting
function getPlainText(e)
{
	var text = "";
	if(e.innerText)
		text = e.innerText;
	else if(e.textContent)
		text = e.textContent;
	return text;
}

// Get the scroll position for window.scrollTo necessary to scroll a given element into view
function ensureVisible(e)
{
	var posTop = findPosY(e);
	var posBot = posTop + e.offsetHeight;
	var winTop = findScrollY();
	var winHeight = findWindowHeight();
	var winBot = winTop + winHeight;
	if(posTop < winTop) {
		return posTop;
	} else if(posBot > winBot) {
		if(e.offsetHeight < winHeight)
			return posTop - (winHeight - e.offsetHeight);
		else
			return posTop;
	} else {
		return winTop;
	}
}

// Get the current width of the display window
function findWindowWidth()
{
	return window.innerWidth || document.documentElement.clientWidth;
}

// Get the current height of the display window
function findWindowHeight()
{
	return window.innerHeight || document.documentElement.clientHeight;
}

// Get the current horizontal page scroll position
function findScrollX()
{
	return window.scrollX || document.documentElement.scrollLeft;
}

// Get the current vertical page scroll position
function findScrollY()
{
	return window.scrollY || document.documentElement.scrollTop;
}

function findPosX(obj)
{
	var curleft = 0;
	while(obj.offsetParent) {
		curleft += obj.offsetLeft;
		obj = obj.offsetParent;
	}
	return curleft;
}

function findPosY(obj)
{
	var curtop = 0;
	while(obj.offsetParent) {
		curtop += obj.offsetTop;
		obj = obj.offsetParent;
	}
	return curtop;
}

// Blur a particular element
function blurElement(e)
{
	if(e && e.focus && e.blur) {
		e.focus();
		e.blur();
	}
}

// Create a non-breaking space
function insertSpacer(place)
{
	var e = document.createTextNode(String.fromCharCode(160));
	if(place)
		place.appendChild(e);
	return e;
}

// Remove all children of a node
function removeChildren(e)
{
	while(e && e.hasChildNodes())
		removeNode(e.firstChild);
}

// Remove a node and all it's children
function removeNode(e)
{
	scrubNode(e);
	e.parentNode.removeChild(e);
}

// Remove any event handlers or non-primitve custom attributes
function scrubNode(e)
{
	if(!config.browser.isIE)
		return;
	var att = e.attributes;
	if(att) {
		for(var t=0; t<att.length; t++) {
			var n = att[t].name;
			if(n !== 'style' && (typeof e[n] === 'function' || (typeof e[n] === 'object' && e[n] != null))) {
				try {
					e[n] = null;
				} catch(ex) {
				}
			}
		}
	}
	var c = e.firstChild;
	while(c) {
		scrubNode(c);
		c = c.nextSibling;
	}
}

// Add a stylesheet, replacing any previous custom stylesheet
function setStylesheet(s,id,doc)
{
	if(!id)
		id = "customStyleSheet";
	if(!doc)
		doc = document;
	var n = doc.getElementById(id);
	if(doc.createStyleSheet) {
		// Test for IE's non-standard createStyleSheet method
		if(n)
			n.parentNode.removeChild(n);
		// This failed without the &nbsp;
		doc.getElementsByTagName("head")[0].insertAdjacentHTML("beforeEnd","&nbsp;<style id='" + id + "'>" + s + "</style>");
	} else {
		if(n) {
			n.replaceChild(doc.createTextNode(s),n.firstChild);
		} else {
			n = doc.createElement("style");
			n.type = "text/css";
			n.id = id;
			n.appendChild(doc.createTextNode(s));
			doc.getElementsByTagName("head")[0].appendChild(n);
		}
	}
}

function removeStyleSheet(id)
{
	var e = document.getElementById(id);
	if(e)
		e.parentNode.removeChild(e);
}

// Force the browser to do a document reflow when needed to workaround browser bugs
function forceReflow()
{
	if(config.browser.isGecko) {
		setStylesheet("body {top:0px;margin-top:0px;}","forceReflow");
		setTimeout(function() {setStylesheet("","forceReflow");},1);
	}
}

// Replace the current selection of a textarea or text input and scroll it into view
function replaceSelection(e,text)
{
	if(e.setSelectionRange) {
		var oldpos = e.selectionStart;
		var isRange = e.selectionEnd > e.selectionStart;
		e.value = e.value.substr(0,e.selectionStart) + text + e.value.substr(e.selectionEnd);
		e.setSelectionRange(isRange ? oldpos : oldpos + text.length,oldpos + text.length);
		var linecount = e.value.split('\n').length;
		var thisline = e.value.substr(0,e.selectionStart).split('\n').length-1;
		e.scrollTop = Math.floor((thisline - e.rows / 2) * e.scrollHeight / linecount);
	} else if(document.selection) {
		var range = document.selection.createRange();
		if(range.parentElement() == e) {
			var isCollapsed = range.text == "";
			range.text = text;
			if(!isCollapsed) {
				range.moveStart('character', -text.length);
				range.select();
			}
		}
	}
}

// Returns the text of the given (text) node, possibly merging subsequent text nodes
function getNodeText(e)
{
	var t = "";
	while(e && e.nodeName == "#text") {
		t += e.nodeValue;
		e = e.nextSibling;
	}
	return t;
}

// Returns true if the element e has a given ancestor element
function isDescendant(e,ancestor)
{
	while(e) {
		if(e === ancestor)
			return true;
		e = e.parentNode;
	}
	return false;
}

//--
//-- LoaderBase and SaverBase
//--

function LoaderBase() {}

LoaderBase.prototype.loadTiddler = function(store,node,tiddlers)
{
	var title = this.getTitle(store,node);
	if(safeMode && store.isShadowTiddler(title))
		return;
	if(title) {
		var tiddler = store.createTiddler(title);
		this.internalizeTiddler(store,tiddler,title,node);
		tiddlers.push(tiddler);
	}
};

LoaderBase.prototype.loadTiddlers = function(store,nodes)
{
	var tiddlers = [];
	for(var t = 0; t < nodes.length; t++) {
		try {
			this.loadTiddler(store,nodes[t],tiddlers);
		} catch(ex) {
			showException(ex,config.messages.tiddlerLoadError.format([this.getTitle(store,nodes[t])]));
		}
	}
	return tiddlers;
};

function SaverBase() {}

SaverBase.prototype.externalize = function(store)
{
	var results = [];
	var tiddlers = store.getTiddlers("title");
	for(var t = 0; t < tiddlers.length; t++) {
		if(!tiddlers[t].doNotSave())
			results.push(this.externalizeTiddler(store, tiddlers[t]));
	}
	return results.join("\n");
};

//--
//-- TW21Loader (inherits from LoaderBase)
//--

function TW21Loader() {}

TW21Loader.prototype = new LoaderBase();

TW21Loader.prototype.getTitle = function(store,node)
{
	var title = null;
	if(node.getAttribute) {
		title = node.getAttribute("title");
		if(!title)
			title = node.getAttribute("tiddler");
	}
	if(!title && node.id) {
		var lenPrefix = store.idPrefix.length;
		if (node.id.substr(0,lenPrefix) == store.idPrefix)
			title = node.id.substr(lenPrefix);
	}
	return title;
};

TW21Loader.prototype.internalizeTiddler = function(store,tiddler,title,node)
{
	var e = node.firstChild;
	var text = null;
	if(node.getAttribute("tiddler")) {
		text = getNodeText(e).unescapeLineBreaks();
	} else {
		while(e.nodeName!="PRE" && e.nodeName!="pre") {
			e = e.nextSibling;
		}
		text = e.innerHTML.replace(/\r/mg,"").htmlDecode();
	}
	var modifier = node.getAttribute("modifier");
	var c = node.getAttribute("created");
	var m = node.getAttribute("modified");
	var created = c ? Date.convertFromYYYYMMDDHHMM(c) : version.date;
	var modified = m ? Date.convertFromYYYYMMDDHHMM(m) : created;
	var tags = node.getAttribute("tags");
	var fields = {};
	var attrs = node.attributes;
	for(var i = attrs.length-1; i >= 0; i--) {
		var name = attrs[i].name;
		if (attrs[i].specified && !TiddlyWiki.isStandardField(name)) {
			fields[name] = attrs[i].value.unescapeLineBreaks();
		}
	}
	tiddler.assign(title,text,modifier,modified,tags,created,fields);
	return tiddler;
};

//--
//-- TW21Saver (inherits from SaverBase)
//--

function TW21Saver() {}

TW21Saver.prototype = new SaverBase();

TW21Saver.prototype.externalizeTiddler = function(store,tiddler)
{
	try {
		var extendedAttributes = "";
		var usePre = config.options.chkUsePreForStorage;
		store.forEachField(tiddler,
			function(tiddler,fieldName,value) {
				// don't store stuff from the temp namespace
				if(typeof value != "string")
					value = "";
				if(!fieldName.match(/^temp\./))
					extendedAttributes += ' %0="%1"'.format([fieldName,value.escapeLineBreaks().htmlEncode()]);
			},true);
		var created = tiddler.created;
		var modified = tiddler.modified;
		var attributes = tiddler.modifier ? ' modifier="' + tiddler.modifier.htmlEncode() + '"' : "";
		attributes += (usePre && created == version.date) ? "" :' created="' + created.convertToYYYYMMDDHHMM() + '"';
		attributes += (usePre && modified == created) ? "" : ' modified="' + modified.convertToYYYYMMDDHHMM() +'"';
		var tags = tiddler.getTags();
		if(!usePre || tags)
			attributes += ' tags="' + tags.htmlEncode() + '"';
		return ('<div %0="%1"%2%3>%4</'+'div>').format([
				usePre ? "title" : "tiddler",
				tiddler.title.htmlEncode(),
				attributes,
				extendedAttributes,
				usePre ? "\n<pre>" + tiddler.text.htmlEncode() + "</pre>\n" : tiddler.text.escapeLineBreaks().htmlEncode()
			]);
	} catch (ex) {
		throw exceptionText(ex,config.messages.tiddlerSaveError.format([tiddler.title]));
	}
};

/************************************************************************************************************/

/**
 * Code Syntax Highlighter.
 * Version 1.5.1
 * Copyright (C) 2004-2007 Alex Gorbatchev.
 * http://www.dreamprojections.com/syntaxhighlighter/
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

//
// create namespaces
//
var dp = {
	sh :
	{
		Toolbar : {},
		Utils	: {},
		RegexLib: {},
		Brushes	: {},
		Strings : {
			AboutDialog : '<html><head><title>About...</title></head><body class="dp-about"><table cellspacing="0"><tr><td class="copy"><p class="title">dp.SyntaxHighlighter</div><div class="para">Version: {V}</p><p><a href="http://www.dreamprojections.com/syntaxhighlighter/?ref=about" target="_blank">http://www.dreamprojections.com/syntaxhighlighter</a></p>&copy;2004-2007 Alex Gorbatchev.</td></tr><tr><td class="footer"><input type="button" class="close" value="OK" onClick="window.close()"/></td></tr></table></body></html>'
		},
		ClipboardSwf : null,
		Version : '1.5.1'
	}
};

// make an alias
dp.SyntaxHighlighter = dp.sh;

//
// Toolbar functions
//

dp.sh.Toolbar.Commands = {
	ExpandSource: {
		label: '+ expand source',
		check: function(highlighter) { return highlighter.collapse; },
		func: function(sender, highlighter)
		{
			sender.parentNode.removeChild(sender);
			highlighter.div.className = highlighter.div.className.replace('collapsed', '');
		}
	},

	// opens a new windows and puts the original unformatted source code inside.
	ViewSource: {
		label: 'view plain',
		func: function(sender, highlighter)
		{
			var code = dp.sh.Utils.FixForBlogger(highlighter.originalCode).replace(/</g, '&lt;');
			var wnd = window.open('', '_blank', 'width=750, height=400, location=0, resizable=1, menubar=0, scrollbars=0');
			wnd.document.write('<textarea style="width:99%;height:99%">' + code + '</textarea>');
			wnd.document.close();
		}
	},

	// Copies the original source code in to the clipboard. Uses either IE only method or Flash object if ClipboardSwf is set
	CopyToClipboard: {
		label: 'copy to clipboard',
		check: function() { return window.clipboardData != null || dp.sh.ClipboardSwf != null; },
		func: function(sender, highlighter)
		{
			var code = dp.sh.Utils.FixForBlogger(highlighter.originalCode)
				.replace(/&lt;/g,'<')
				.replace(/&gt;/g,'>')
				.replace(/&amp;/g,'&')
			;

			if(window.clipboardData)
			{
				window.clipboardData.setData('text', code);
			}
			else if(dp.sh.ClipboardSwf != null)
			{
				var flashcopier = highlighter.flashCopier;

				if(flashcopier == null)
				{
					flashcopier = document.createElement('div');
					highlighter.flashCopier = flashcopier;
					highlighter.div.appendChild(flashcopier);
				}

				flashcopier.innerHTML = '<embed src="' + dp.sh.ClipboardSwf + '" FlashVars="clipboard='+encodeURIComponent(code)+'" width="0" height="0" type="application/x-shockwave-flash"></embed>';
			}

			alert('The code is in your clipboard now');
		}
	},

	// creates an invisible iframe, puts the original source code inside and prints it
	PrintSource: {
		label: 'print',
		func: function(sender, highlighter)
		{
			var iframe = document.createElement('IFRAME');
			var doc = null;

			// this hides the iframe
			iframe.style.cssText = 'position:absolute;width:0px;height:0px;left:-500px;top:-500px;';

			document.body.appendChild(iframe);
			doc = iframe.contentWindow.document;

			dp.sh.Utils.CopyStyles(doc, window.document);
			doc.write('<div class="' + highlighter.div.className.replace('collapsed', '') + ' printing">' + highlighter.div.innerHTML + '</div>');
			doc.close();

			iframe.contentWindow.focus();
			iframe.contentWindow.print();

			alert('Printing...');

			document.body.removeChild(iframe);
		}
	},

	About: {
		label: '?',
		func: function(highlighter)
		{
			var wnd	= window.open('', '_blank', 'dialog,width=300,height=150,scrollbars=0');
			var doc	= wnd.document;

			dp.sh.Utils.CopyStyles(doc, window.document);

			doc.write(dp.sh.Strings.AboutDialog.replace('{V}', dp.sh.Version));
			doc.close();
			wnd.focus();
		}
	}
};

// creates a <div /> with all toolbar links
dp.sh.Toolbar.Create = function(highlighter)
{
	var div = document.createElement('DIV');

	div.className = 'tools';

	for(var name in dp.sh.Toolbar.Commands)
	{
		var cmd = dp.sh.Toolbar.Commands[name];

		if(cmd.check != null && !cmd.check(highlighter))
			continue;

		div.innerHTML += '<a href="#" onclick="dp.sh.Toolbar.Command(\'' + name + '\',this);return false;">' + cmd.label + '</a>';
	}

	return div;
}

// executes toolbar command by name
dp.sh.Toolbar.Command = function(name, sender)
{
	var n = sender;

	while(n != null && n.className.indexOf('dp-highlighter') == -1)
		n = n.parentNode;

	if(n != null)
		dp.sh.Toolbar.Commands[name].func(sender, n.highlighter);
}

// copies all <link rel="stylesheet" /> from 'target' window to 'dest'
dp.sh.Utils.CopyStyles = function(destDoc, sourceDoc)
{
	var links = sourceDoc.getElementsByTagName('link');

	for(var i = 0; i < links.length; i++)
		if(links[i].rel.toLowerCase() == 'stylesheet')
			destDoc.write('<link type="text/css" rel="stylesheet" href="' + links[i].href + '"></link>');
}

dp.sh.Utils.FixForBlogger = function(str)
{
	return (dp.sh.isBloggerMode == true) ? str.replace(/<br\s*\/?>|&lt;br\s*\/?&gt;/gi, '\n') : str;
}

//
// Common reusable regular expressions
//
dp.sh.RegexLib = {
	MultiLineCComments : new RegExp('/\\*[\\s\\S]*?\\*/', 'gm'),
	SingleLineCComments : new RegExp('//.*$', 'gm'),
	SingleLinePerlComments : new RegExp('#.*$', 'gm'),
	DoubleQuotedString : new RegExp('"(?:\\.|(\\\\\\")|[^\\""\\n])*"','g'),
	SingleQuotedString : new RegExp("'(?:\\.|(\\\\\\')|[^\\''\\n])*'", 'g')
};

//
// Match object
//
dp.sh.Match = function(value, index, css)
{
	this.value = value;
	this.index = index;
	this.length = value.length;
	this.css = css;
}

//
// Highlighter object
//
dp.sh.Highlighter = function()
{
	this.noGutter = false;
	this.addControls = true;
	this.collapse = false;
	this.tabsToSpaces = true;
	this.wrapColumn = 80;
	this.showColumns = true;
}

// static callback for the match sorting
dp.sh.Highlighter.SortCallback = function(m1, m2)
{
	// sort matches by index first
	if(m1.index < m2.index)
		return -1;
	else if(m1.index > m2.index)
		return 1;
	else
	{
		// if index is the same, sort by length
		if(m1.length < m2.length)
			return -1;
		else if(m1.length > m2.length)
			return 1;
	}
	return 0;
}

dp.sh.Highlighter.prototype.CreateElement = function(name)
{
	var result = document.createElement(name);
	result.highlighter = this;
	return result;
}

// gets a list of all matches for a given regular expression
dp.sh.Highlighter.prototype.GetMatches = function(regex, css)
{
	var index = 0;
	var match = null;

	while((match = regex.exec(this.code)) != null)
		this.matches[this.matches.length] = new dp.sh.Match(match[0], match.index, css);
}

dp.sh.Highlighter.prototype.AddBit = function(str, css)
{
	if(str == null || str.length == 0)
		return;

	var span = this.CreateElement('SPAN');

//	str = str.replace(/&/g, '&amp;');
	str = str.replace(/ /g, '&nbsp;');
	str = str.replace(/</g, '&lt;');
//	str = str.replace(/&lt;/g, '<');
//	str = str.replace(/>/g, '&gt;');
	str = str.replace(/\n/gm, '&nbsp;<br>');

	// when adding a piece of code, check to see if it has line breaks in it
	// and if it does, wrap individual line breaks with span tags
	if(css != null)
	{
		if((/br/gi).test(str))
		{
			var lines = str.split('&nbsp;<br>');

			for(var i = 0; i < lines.length; i++)
			{
				span = this.CreateElement('SPAN');
				span.className = css;
				span.innerHTML = lines[i];

				this.div.appendChild(span);

				// don't add a <BR> for the last line
				if(i + 1 < lines.length)
					this.div.appendChild(this.CreateElement('BR'));
			}
		}
		else
		{
			span.className = css;
			span.innerHTML = str;
			this.div.appendChild(span);
		}
	}
	else
	{
		span.innerHTML = str;
		this.div.appendChild(span);
	}
}

// checks if one match is inside any other match
dp.sh.Highlighter.prototype.IsInside = function(match)
{
	if(match == null || match.length == 0)
		return false;

	for(var i = 0; i < this.matches.length; i++)
	{
		var c = this.matches[i];

		if(c == null)
			continue;

		if((match.index > c.index) && (match.index < c.index + c.length))
			return true;
	}

	return false;
}

dp.sh.Highlighter.prototype.ProcessRegexList = function()
{
	for(var i = 0; i < this.regexList.length; i++)
		this.GetMatches(this.regexList[i].regex, this.regexList[i].css);
}

dp.sh.Highlighter.prototype.ProcessSmartTabs = function(code)
{
	var lines	= code.split('\n');
	var result	= '';
	var tabSize	= 4;
	var tab		= '\t';

	// This function inserts specified amount of spaces in the string
	// where a tab is while removing that given tab.
	function InsertSpaces(line, pos, count)
	{
		var left	= line.substr(0, pos);
		var right	= line.substr(pos + 1, line.length);	// pos + 1 will get rid of the tab
		var spaces	= '';

		for(var i = 0; i < count; i++)
			spaces += ' ';

		return left + spaces + right;
	}

	// This function process one line for 'smart tabs'
	function ProcessLine(line, tabSize)
	{
		if(line.indexOf(tab) == -1)
			return line;

		var pos = 0;

		while((pos = line.indexOf(tab)) != -1)
		{
			// This is pretty much all there is to the 'smart tabs' logic.
			// Based on the position within the line and size of a tab,
			// calculate the amount of spaces we need to insert.
			var spaces = tabSize - pos % tabSize;

			line = InsertSpaces(line, pos, spaces);
		}

		return line;
	}

	// Go through all the lines and do the 'smart tabs' magic.
	for(var i = 0; i < lines.length; i++)
		result += ProcessLine(lines[i], tabSize) + '\n';

	return result;
}

dp.sh.Highlighter.prototype.SwitchToList = function()
{
	// thanks to Lachlan Donald from SitePoint.com for this <br/> tag fix.
	var html = this.div.innerHTML.replace(/<(br)\/?>/gi, '\n');
	var lines = html.split('\n');

	if(this.addControls == true)
		this.bar.appendChild(dp.sh.Toolbar.Create(this));

	// add columns ruler
	if(this.showColumns)
	{
		var div = this.CreateElement('div');
		var columns = this.CreateElement('div');
		var showEvery = 10;
		var i = 1;

		while(i <= 150)
		{
			if(i % showEvery == 0)
			{
				div.innerHTML += i;
				i += (i + '').length;
			}
			else
			{
				div.innerHTML += '&middot;';
				i++;
			}
		}

		columns.className = 'columns';
		columns.appendChild(div);
		this.bar.appendChild(columns);
	}

	for(var i = 0, lineIndex = this.firstLine; i < lines.length - 1; i++, lineIndex++)
	{
		var li = this.CreateElement('LI');
		var span = this.CreateElement('SPAN');

		// uses .line1 and .line2 css styles for alternating lines
		li.className = (i % 2 == 0) ? 'alt' : '';
		span.innerHTML = lines[i] + '&nbsp;';

		li.appendChild(span);
		this.ol.appendChild(li);
	}

	this.div.innerHTML	= '';
}

dp.sh.Highlighter.prototype.Highlight = function(code)
{
	function Trim(str)
	{
		return str.replace(/^\s*(.*?)[\s\n]*$/g, '$1');
	}

	function Chop(str)
	{
		return str.replace(/\n*$/, '').replace(/^\n*/, '');
	}

	function Unindent(str)
	{
		var lines = dp.sh.Utils.FixForBlogger(str).split('\n');
		var indents = new Array();
		var regex = new RegExp('^\\s*', 'g');
		var min = 1000;

		// go through every line and check for common number of indents
		for(var i = 0; i < lines.length && min > 0; i++)
		{
			if(Trim(lines[i]).length == 0)
				continue;

			var matches = regex.exec(lines[i]);

			if(matches != null && matches.length > 0)
				min = Math.min(matches[0].length, min);
		}

		// trim minimum common number of white space from the begining of every line
		if(min > 0)
			for(var i = 0; i < lines.length; i++)
				lines[i] = lines[i].substr(min);

		return lines.join('\n');
	}

	// This function returns a portions of the string from pos1 to pos2 inclusive
	function Copy(string, pos1, pos2)
	{
		return string.substr(pos1, pos2 - pos1);
	}

	var pos	= 0;

	if(code == null)
		code = '';

	this.originalCode = code;
	this.code = Chop(Unindent(code));
	this.div = this.CreateElement('DIV');
	this.bar = this.CreateElement('DIV');
	this.ol = this.CreateElement('OL');
	this.matches = new Array();

	this.div.className = 'dp-highlighter';
	this.div.highlighter = this;

	this.bar.className = 'bar';

	// set the first line
	this.ol.start = this.firstLine;

	if(this.CssClass != null)
		this.ol.className = this.CssClass;

	if(this.collapse)
		this.div.className += ' collapsed';

	if(this.noGutter)
		this.div.className += ' nogutter';

	// replace tabs with spaces
	if(this.tabsToSpaces == true)
		this.code = this.ProcessSmartTabs(this.code);

	this.ProcessRegexList();

	// if no matches found, add entire code as plain text
	if(this.matches.length == 0)
	{
		this.AddBit(this.code, null);
		this.SwitchToList();
		this.div.appendChild(this.bar);
		this.div.appendChild(this.ol);
		return;
	}

	// sort the matches
	this.matches = this.matches.sort(dp.sh.Highlighter.SortCallback);

	// The following loop checks to see if any of the matches are inside
	// of other matches. This process would get rid of highligted strings
	// inside comments, keywords inside strings and so on.
	for(var i = 0; i < this.matches.length; i++)
		if(this.IsInside(this.matches[i]))
			this.matches[i] = null;

	// Finally, go through the final list of matches and pull the all
	// together adding everything in between that isn't a match.
	for(var i = 0; i < this.matches.length; i++)
	{
		var match = this.matches[i];

		if(match == null || match.length == 0)
			continue;

		this.AddBit(Copy(this.code, pos, match.index), null);
		this.AddBit(match.value, match.css);

		pos = match.index + match.length;
	}

	this.AddBit(this.code.substr(pos), null);

	this.SwitchToList();
	this.div.appendChild(this.bar);
	this.div.appendChild(this.ol);
}

dp.sh.Highlighter.prototype.GetKeywords = function(str)
{
	return '\\b' + str.replace(/ /g, '\\b|\\b') + '\\b';
}

dp.sh.BloggerMode = function()
{
	dp.sh.isBloggerMode = true;
}

// highlightes all elements identified by name and gets source code from specified property
dp.sh.HighlightAll = function(name, showGutter /* optional */, showControls /* optional */, collapseAll /* optional */, firstLine /* optional */, showColumns /* optional */)
{
	function FindValue()
	{
		var a = arguments;

		for(var i = 0; i < a.length; i++)
		{
			if(a[i] == null)
				continue;

			if(typeof(a[i]) == 'string' && a[i] != '')
				return a[i] + '';

			if(typeof(a[i]) == 'object' && a[i].value != '')
				return a[i].value + '';
		}

		return null;
	}

	function IsOptionSet(value, list)
	{
		for(var i = 0; i < list.length; i++)
			if(list[i] == value)
				return true;

		return false;
	}

	function GetOptionValue(name, list, defaultValue)
	{
		var regex = new RegExp('^' + name + '\\[(\\w+)\\]$', 'gi');
		var matches = null;

		for(var i = 0; i < list.length; i++)
			if((matches = regex.exec(list[i])) != null)
				return matches[1];

		return defaultValue;
	}

	function FindTagsByName(list, name, tagName)
	{
		var tags = document.getElementsByTagName(tagName);

		for(var i = 0; i < tags.length; i++)
			if(tags[i].getAttribute('name') == name)
				list.push(tags[i]);
	}

	var elements = [];
	var highlighter = null;
	var registered = {};
	var propertyName = 'innerHTML';

	// for some reason IE doesn't find <pre/> by name, however it does see them just fine by tag name...
	FindTagsByName(elements, name, 'pre');
	FindTagsByName(elements, name, 'textarea');

	if(elements.length == 0)
		return;

	// register all brushes
	for(var brush in dp.sh.Brushes)
	{
		var aliases = dp.sh.Brushes[brush].Aliases;

		if(aliases == null)
			continue;

		for(var i = 0; i < aliases.length; i++)
			registered[aliases[i]] = brush;
	}

	for(var i = 0; i < elements.length; i++)
	{
		var element = elements[i];
		var options = FindValue(
				element.attributes['class'], element.className,
				element.attributes['language'], element.language
				);
		var language = '';

		if(options == null)
			continue;

		options = options.split(':');

		language = options[0].toLowerCase();

		if(registered[language] == null)
			continue;

		// instantiate a brush
		highlighter = new dp.sh.Brushes[registered[language]]();

		// hide the original element
		element.style.display = 'none';

		highlighter.noGutter = (showGutter == null) ? IsOptionSet('nogutter', options) : !showGutter;
		highlighter.addControls = (showControls == null) ? !IsOptionSet('nocontrols', options) : showControls;
		highlighter.collapse = (collapseAll == null) ? IsOptionSet('collapse', options) : collapseAll;
		highlighter.showColumns = (showColumns == null) ? IsOptionSet('showcolumns', options) : showColumns;

		// write out custom brush style
		var headNode = document.getElementsByTagName('head')[0];
		if(highlighter.Style && headNode)
		{
			var styleNode = document.createElement('style');
			styleNode.setAttribute('type', 'text/css');

			if(styleNode.styleSheet) // for IE
			{
				styleNode.styleSheet.cssText = highlighter.Style;
			}
			else // for everyone else
			{
				var textNode = document.createTextNode(highlighter.Style);
				styleNode.appendChild(textNode);
			}

			headNode.appendChild(styleNode);
		}

		// first line idea comes from Andrew Collington, thanks!
		highlighter.firstLine = (firstLine == null) ? parseInt(GetOptionValue('firstline', options, 1)) : firstLine;

		highlighter.Highlight(element[propertyName]);

		highlighter.source = element;

		element.parentNode.insertBefore(highlighter.div, element);
	}
}

/**
 * Code Syntax Highlighter Plugin for TiddlyWiki.
 * Version 1.0 (SyntaxHighLighter: 1.5.1, TiddlyWiki: 2.4.1)
 * Copyright (C) 2008 andot.
 * http://www.coolcode.cn/show-310-1.html
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

dp.sh.ClipboardSwf = 'clipboard.swf';

dp.sh.Highlight = function (element, options, showGutter /* optional */, showControls /* optional */, collapseAll /* optional */, firstLine /* optional */, showColumns /* optional */) {
    function FindValue()
    {
        var a = arguments;

        for(var i = 0; i < a.length; i++)
        {
            if(a[i] == null)
                continue;

            if(typeof(a[i]) == 'string' && a[i] != '')
                return a[i] + '';

            if(typeof(a[i]) == 'object' && a[i].value != '')
                return a[i].value + '';
        }

        return null;
    }

    function IsOptionSet(value, list)
    {
        for(var i = 0; i < list.length; i++)
            if(list[i] == value)
                return true;

        return false;
    }

    function GetOptionValue(name, list, defaultValue)
    {
        var regex = new RegExp('^' + name + '\\[(\\w+)\\]$', 'gi');
        var matches = null;

        for(var i = 0; i < list.length; i++)
            if((matches = regex.exec(list[i])) != null)
                return matches[1];

        return defaultValue;
    }
	var highlighter = null;
	var propertyName = 'innerHTML';

    if(this.registered == undefined) {
        var registered = {};
    	// register all brushes
	    for(var brush in dp.sh.Brushes)
	    {
		    var aliases = dp.sh.Brushes[brush].Aliases;

		    if(aliases == null)
			    continue;

		    for(var i = 0; i < aliases.length; i++)
			    registered[aliases[i]] = brush;
	    }
        this.registered = registered;
    }

    options = options.split(':');

    language = options[0].toLowerCase();

    if(this.registered[language] == null) return;

    // instantiate a brush
    highlighter = new dp.sh.Brushes[this.registered[language]]();

    // hide the original element
    element.style.display = 'none';

    highlighter.noGutter = (showGutter == null) ? IsOptionSet('nogutter', options) : !showGutter;
    highlighter.addControls = (showControls == null) ? !IsOptionSet('nocontrols', options) : showControls;
    highlighter.collapse = (collapseAll == null) ? IsOptionSet('collapse', options) : collapseAll;
    highlighter.showColumns = (showColumns == null) ? IsOptionSet('showcolumns', options) : showColumns;

    // write out custom brush style
    var headNode = document.getElementsByTagName('head')[0];
    var styleNode = document.getElementById(highlighter.CssClass);
    if(highlighter.Style && headNode && !styleNode)
    {
        var styleNode = document.createElement('style');
        styleNode.setAttribute('id', highlighter.CssClass);
        styleNode.setAttribute('type', 'text/css');

        if(styleNode.styleSheet) // for IE
        {
            styleNode.styleSheet.cssText = highlighter.Style;
        }
        else // for everyone else
        {
            var textNode = document.createTextNode(highlighter.Style);
            styleNode.appendChild(textNode);
        }

        headNode.appendChild(styleNode);
    }

    // first line idea comes from Andrew Collington, thanks!
    highlighter.firstLine = (firstLine == null) ? parseInt(GetOptionValue('firstline', options, 1)) : firstLine;

    highlighter.Highlight(element[propertyName]);

    highlighter.source = element;

    element.parentNode.insertBefore(highlighter.div, element);
}

config.formatters.push({
	name: "SyntaxHighlighter",
	match: "^<code[\\s]+[^>]+>\\n",
	element: "pre",
	handler: function(w)
	{
        this.lookaheadRegExp = /<code[\s]+([^>]+)>\n((?:^[^\n]*\n)+?)(^<\/code>$\n?)/mg;
		this.lookaheadRegExp.lastIndex = w.matchStart;
		var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
		if(lookaheadMatch && lookaheadMatch.index == w.matchStart) {
            var options = lookaheadMatch[1];
			var text = lookaheadMatch[2];
			if(config.browser.isIE)
				text = text.replace(/\n/g,"\r");
			var element = createTiddlyElement(w.output,this.element,null,null,text);
            dp.sh.Highlight(element, options);
			w.nextMatch = lookaheadMatch.index + lookaheadMatch[0].length;
		}
	}
});

config.formatterHelpers.enclosedTextHelper = function(w) {
	this.lookaheadRegExp.lastIndex = w.matchStart;
	var lookaheadMatch = this.lookaheadRegExp.exec(w.source);
	if(lookaheadMatch && lookaheadMatch.index == w.matchStart) {
		var text = lookaheadMatch[1];
		if(config.browser.isIE)
			text = text.replace(/\n/g,"\r");
		var element = createTiddlyElement(w.output,this.element,null,null,text);
		switch(w.matchText) {
		case "/*{{{*/\n": // CSS
			dp.sh.Highlight(element, 'css');
			break;
		case "//{{{\n": // plugin
			dp.sh.Highlight(element, 'js');
			break;
		case "<!--{{{-->\n": //template
			dp.sh.Highlight(element, 'xml');
			break;
		}
		w.nextMatch = lookaheadMatch.index + lookaheadMatch[0].length;
	}
}

/*
 * AS3 Syntax
 * @author Mark Walters
 * http://www.digitalflipbook.com
*/

dp.sh.Brushes.AS3 = function()
{
	var definitions =	'class interface package';

	var keywords =	'Array Boolean Date decodeURI decodeURIComponent encodeURI encodeURIComponent escape ' +
					'int isFinite isNaN isXMLName Number Object parseFloat parseInt ' +
					'String trace uint unescape XML XMLList ' + //global functions

					'Infinity -Infinity NaN undefined ' + //global constants

					'as delete instanceof is new typeof ' + //operators

					'break case catch continue default do each else finally for if in ' +
					'label return super switch throw try while with ' + //statements

					'dynamic final internal native override private protected public static ' + //attributes

					'...rest const extends function get implements namespace set ' + //definitions

					'import include use ' + //directives

					'AS3 flash_proxy object_proxy ' + //namespaces

					'false null this true ' + //expressions

					'void Null'; //types

	this.regexList = [
		{ regex: dp.sh.RegexLib.SingleLineCComments,				css: 'comment' },			// one line comments
		{ regex: dp.sh.RegexLib.MultiLineCComments,					css: 'blockcomment' },		// multiline comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,					css: 'string' },			// double quoted strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,					css: 'string' },			// single quoted strings
		{ regex: new RegExp('^\\s*#.*', 'gm'),						css: 'preprocessor' },		// preprocessor tags like #region and #endregion
		{ regex: new RegExp(this.GetKeywords(definitions), 'gm'),	css: 'definition' },		// definitions
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),		css: 'keyword' },			// keywords
		{ regex: new RegExp('var', 'gm'),							css: 'variable' }			// variable
		];

	this.CssClass = 'dp-as';
	this.Style =	'.dp-as .comment { color: #009900; font-style: italic; }' +
					'.dp-as .blockcomment { color: #3f5fbf; }' +
					'.dp-as .string { color: #990000; }' +
					'.dp-as .preprocessor { color: #0033ff; }' +
					'.dp-as .definition { color: #9900cc; font-weight: bold; }' +
					'.dp-as .keyword { color: #0033ff; }' +
					'.dp-as .variable { color: #6699cc; font-weight: bold; }';
}

dp.sh.Brushes.AS3.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.AS3.Aliases	= ['as', 'actionscript', 'ActionScript', 'as3', 'AS3'];

/**
 *  Author: Sa鷏 Mart韓ez Vidals
 *  http://buglog-saul.blogspot.com/
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, version 3 of the License.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

dp.sh.Brushes.Bash = function()
{
    var builtins =  'alias bg bind break builtin cd command compgen complete continue ' +
                    'declare dirs disown echo enable eval exec exit export fc fg ' +
                    'getopts hash help history jobs kill let local logout popd printf ' +
                    'pushd pwd read readonly return set shift shopt source ' +
                    'suspend test times trap type typeset ulimit umask unalias unset wait';

    var keywords =  'case do done elif else esac fi for function if in select then ' +
                    'time until while';

    this.regexList = [
                    /* cometarios */
                    {regex: dp.sh.RegexLib.SingleLinePerlComments, css: 'comment'},
                    /* cadenas de texto */
                    {regex: dp.sh.RegexLib.DoubleQuotedString, css: 'string'},
                    {regex: dp.sh.RegexLib.SingleQuotedString, css: 'string'},
                    /* delimitadores */
                    {regex: new RegExp('[()[\\]{}]', 'g'), css: 'delim'},
                    /* variables */
                    {regex: new RegExp('\\$\\w+', 'g'), css: 'vars'},
                    {regex: new RegExp('\\w+=', 'g'), css: 'vars'},
                    /* banderas */
                    {regex: new RegExp('\\s-\\w+', 'g'), css: 'flag'},
                    /* builtins */
                    {regex: new RegExp(this.GetKeywords(builtins), 'gm'), css: 'builtin'},
                    /* palabras reservadas */
                    {regex: new RegExp(this.GetKeywords(keywords), 'gm'), css: 'keyword'}
                    ];

    this.CssClass = 'dp-bash';

    this.Style =    '.dp-bash .builtin {color: maroon; font-weight: bold;}' +
                    '.dp-bash .comment {color: gray;}' +
                    '.dp-bash .delim {font-weight: bold;}' +
                    '.dp-bash .flag {color: green;}' +
                    '.dp-bash .string {color: red;}' +
                    '.dp-bash .vars {color: blue;}';

}

dp.sh.Brushes.Bash.prototype = new dp.sh.Highlighter();
dp.sh.Brushes.Bash.Aliases = ['bash', 'sh'];

dp.sh.Brushes.Batch = function()
{
    var builtins =  'APPEND ATTRIB CD CHDIR CHKDSK CHOICE CLS COPY DEL ERASE DELTREE ' +
                    'DIR EXIT FC COMP FDISK FIND FORMAT FSUTIL HELP JOIN ' +
                    'LABEL LOADFIX MK MKDIR MEM MEMMAKER MORE MOVE MSD PCPARK ' +
                    'PRINT RD RMDIR REN SCANDISK SHARE SORT SUBST SYS ' +
                    'TIME DATE TREE TRUENAME TYPE UNDELETE VER XCOPY';

    var keywords =  'DO ELSE FOR IN CALL CHOICE GOTO SHIFT PAUSE ERRORLEVEL ' +
      'IF NOT EXIST LFNFOR START SETLOCAL ENDLOCAL ECHO SET';

    this.regexList = [
 {regex: new RegExp('REM.*$', 'gm'), css: 'comment'},
 {regex: new RegExp('::.*$', 'gm'), css: 'comment'},
 {regex: dp.sh.RegexLib.DoubleQuotedString, css: 'string'},
 {regex: dp.sh.RegexLib.SingleQuotedString, css: 'string'},
 {regex: new RegExp('[()[\\]{}]', 'g'), css: 'delim'},
 {regex: new RegExp('%\\w+%', 'g'), css: 'vars'},
 {regex: new RegExp('%%\\w+', 'g'), css: 'vars'},
 {regex: new RegExp('\\w+=', 'g'), css: 'vars'},
 {regex: new RegExp('@\\w+', 'g'), css: 'keyword'},
 {regex: new RegExp(':\\w+', 'g'), css: 'keyword'},
 {regex: new RegExp('\\s/\\w+', 'g'), css: 'flag'},
 {regex: new RegExp(this.GetKeywords(builtins), 'gm'), css: 'builtin'},
 {regex: new RegExp(this.GetKeywords(keywords), 'gm'), css: 'keyword'}
 ];

    this.CssClass = 'dp-batch';

    this.Style =    '.dp-batch .builtin {color: maroon; font-weight: bold;}' +
                    '.dp-batch .comment {color: gray;}' +
                    '.dp-batch .delim {font-weight: bold;}' +
                    '.dp-batch .flag {color: green;}' +
                    '.dp-batch .string {color: red;}' +
                    '.dp-batch .vars {color: blue;font-weight: bold;}';

}

dp.sh.Brushes.Batch.prototype = new dp.sh.Highlighter();
dp.sh.Brushes.Batch.Aliases = ['batch', 'dos'];

dp.sh.Brushes.ColdFusion = function()
{
	this.CssClass		=	'dp-coldfusion';
	this.Style			=	'.dp-coldfusion { font: 13px "Courier New", Courier, monospace; }' +
							'.dp-coldfusion .tag, .dp-coldfusion .tag-name { color: #990033; }' +
							'.dp-coldfusion .attribute { color: #990033; }' +
							'.dp-coldfusion .attribute-value { color: #0000FF; }' +
							'.dp-coldfusion .cfcomments { background-color: #FFFF99; color: #000000; }' +
							'.dp-coldfusion .cfscriptcomments { color: #999999; }' +
							'.dp-coldfusion .keywords { color: #0000FF; }' +
							'.dp-coldfusion .mgkeywords { color: #CC9900; }' +
							'.dp-coldfusion .numbers { color: #ff0000; }' +
							'.dp-coldfusion .strings { color: green; }';

	this.mgKeywords		=	'setvalue getvalue addresult viewcollection viewstate';

	this.keywords		=	'var eq neq gt gte lt lte not and or true false ' +
							'abs acos addsoaprequestheader addsoapresponseheader ' +
							'arrayappend arrayavg arrayclear arraydeleteat arrayinsertat ' +
							'arrayisempty arraylen arraymax arraymin arraynew ' +
							'arrayprepend arrayresize arrayset arraysort arraysum ' +
							'arrayswap arraytolist asc asin atn binarydecode binaryencode ' +
							'bitand bitmaskclear bitmaskread bitmaskset bitnot bitor bitshln ' +
							'bitshrn bitxor ceiling charsetdecode charsetencode chr cjustify ' +
							'compare comparenocase cos createdate createdatetime createobject ' +
							'createobject createobject createobject createobject createodbcdate ' +
							'createodbcdatetime createodbctime createtime createtimespan ' +
							'createuuid dateadd datecompare dateconvert datediff dateformat ' +
							'datepart day dayofweek dayofweekasstring dayofyear daysinmonth ' +
							'daysinyear de decimalformat decrementvalue decrypt decryptbinary ' +
							'deleteclientvariable directoryexists dollarformat duplicate encrypt ' +
							'encryptbinary evaluate exp expandpath fileexists find findnocase ' +
							'findoneof firstdayofmonth fix formatbasen generatesecretkey ' +
							'getauthuser getbasetagdata getbasetaglist getbasetemplatepath ' +
							'getclientvariableslist getcontextroot getcurrenttemplatepath ' +
							'getdirectoryfrompath getencoding getexception getfilefrompath ' +
							'getfunctionlist getgatewayhelper gethttprequestdata gethttptimestring ' +
							'getk2serverdoccount getk2serverdoccountlimit getlocale ' +
							'getlocaledisplayname getlocalhostip getmetadata getmetricdata ' +
							'getpagecontext getprofilesections getprofilestring getsoaprequest ' +
							'getsoaprequestheader getsoapresponse getsoapresponseheader ' +
							'gettempdirectory gettempfile gettemplatepath gettickcount ' +
							'gettimezoneinfo gettoken hash hour htmlcodeformat htmleditformat ' +
							'iif incrementvalue inputbasen insert int isarray isbinary isboolean ' +
							'iscustomfunction isdate isdebugmode isdefined isk2serverabroker ' +
							'isk2serverdoccountexceeded isk2serveronline isleapyear islocalhost ' +
							'isnumeric isnumericdate isobject isquery issimplevalue issoaprequest ' +
							'isstruct isuserinrole isvalid isvalid isvalid iswddx isxml ' +
							'isxmlattribute isxmldoc isxmlelem isxmlnode isxmlroot javacast ' +
							'jsstringformat lcase left len listappend listchangedelims listcontains ' +
							'listcontainsnocase listdeleteat listfind listfindnocase listfirst ' +
							'listgetat listinsertat listlast listlen listprepend listqualify ' +
							'listrest listsetat listsort listtoarray listvaluecount ' +
							'listvaluecountnocase ljustify log log10 lscurrencyformat lsdateformat ' +
							'lseurocurrencyformat lsiscurrency lsisdate lsisnumeric lsnumberformat ' +
							'lsparsecurrency lsparsedatetime lsparseeurocurrency lsparsenumber ' +
							'lstimeformat ltrim max mid min minute month monthasstring now ' +
							'numberformat paragraphformat parameterexists parsedatetime pi ' +
							'preservesinglequotes quarter queryaddcolumn queryaddrow querynew ' +
							'querysetcell quotedvaluelist rand randomize randrange refind ' +
							'refindnocase releasecomobject removechars repeatstring replace ' +
							'replacelist replacenocase rereplace rereplacenocase reverse right ' +
							'rjustify round rtrim second sendgatewaymessage setencoding ' +
							'setlocale setprofilestring setvariable sgn sin spanexcluding ' +
							'spanincluding sqr stripcr structappend structclear structcopy ' +
							'structcount structdelete structfind structfindkey structfindvalue ' +
							'structget structinsert structisempty structkeyarray structkeyexists ' +
							'structkeylist structnew structsort structupdate tan timeformat ' +
							'tobase64 tobinary toscript tostring trim ucase urldecode urlencodedformat ' +
							'urlsessionformat val valuelist week wrap writeoutput xmlchildpos ' +
							'xmlelemnew xmlformat xmlgetnodetype xmlnew xmlparse xmlsearch xmltransform ' +
							'xmlvalidate year yesnoformat';

	// Array to hold the possible string matches
	this.stringMatches	=	new Array();
	this.attributeMatches	=	new Array();
}

dp.sh.Brushes.ColdFusion.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.ColdFusion.Aliases	= ['coldfusion', 'cf'];

dp.sh.Brushes.ColdFusion.prototype.ProcessRegexList = function()
{
	function push(array, value)
	{
		array[array.length] = value;
	}

	function find(array, element)
	{
		for(var i = 0; i < array.length; i++){
			if(array[i] == element){
				return i;
			}
		}

		return -1;
	}

	var match	= null;
	var regex	= null;

	// Match numbers
	// (\\d+)
	this.GetMatches(new RegExp('\\b(\\d+)', 'gm'), 'numbers');

	// Match mg keywords
	this.GetMatches(new RegExp(this.GetKeywords(this.mgKeywords), 'igm'), 'mgkeywords');

	// Match single line comments via the built in single line regex (for cfscript)
	this.GetMatches(dp.sh.RegexLib.SingleLineCComments, 'cfscriptcomments');

	// Match multi line comments via the built in multi line regex (for cfscript)
	this.GetMatches(dp.sh.RegexLib.MultiLineCComments, 'cfscriptcomments');

	// Match tag based comments (including multiline comments)
	// (\&lt;|<)!---[\\s\\S]*?---(\&gt;|>)
	this.GetMatches(new RegExp('(\&lt;|<)!---[\\s\\S]*?---(\&gt;|>)', 'gm'), 'cfcomments');

	// Match attributes and their values excluding cfset tags
	// (cfset\\s*)?([:\\w-\.]+)\\s*=\\s*(".*?"|\'.*?\')*
	regex = new RegExp('(cfset\\s*)?([:\\w-\.]+)\\s*=\\s*(".*?"|\'.*?\')*', 'gm');
	while((match = regex.exec(this.code)) != null)
	{
		// If there is match in element 1 (the tag is cfset), continute to the next match
		if (match[1] != undefined && match[1] != '')
		{
			continue;
		}

		// Add the atribute to the matches only if it has a matching value (dbtype="query")
		// and the match is not an empty string
		if (match[3] != undefined && match[3] != '' && match[3] != '""' && match[3] != "''")
		{
			push(this.matches, new dp.sh.Match(match[2], match.index, 'attribute'));
			push(this.matches, new dp.sh.Match(match[3], match.index + match[0].indexOf(match[3]), 'attribute-value'));
			// Add the attribute value to the array of string matches
			push(this.stringMatches, match[3]);

			// Add the attribute to the array of attribute matches
			push(this.attributeMatches, match[2]);
		}
	}

	// Match opening and closing tag brackets
	// (\&lt;|<)/*\?*(?!\!)|/*\?*(\&gt;|>)
	this.GetMatches(new RegExp('(\&lt;|<)/*\\?*(?!\\!)|/*\\?*(\&gt;|>)', 'gm'), 'tag');

	// Match tag names
	// (\&lt;|<)/*\?*\s*(\w+)
	regex = new RegExp('(?:\&lt;|<)/*\\?*\\s*([:\\w-\.]+)', 'gm');
	while((match = regex.exec(this.code)) != null)
	{
		push(this.matches, new dp.sh.Match(match[1], match.index + match[0].indexOf(match[1]), 'tag-name'));
	}

	// Match keywords
	regex = new RegExp(this.GetKeywords(this.keywords), 'igm');
	while((match = regex.exec(this.code)) != null)
	{
		// if a match exists (there is a value for the attribute)
		if (find(this.attributeMatches, match[0]) == -1)
		{
			push(this.matches, new dp.sh.Match(match[0], match.index, 'keywords'));
		}
	}

	// Match cfset tags and quoated attributes
	regex = new RegExp('cfset\\s*.*(".*?"|\'.*?\')', 'gm');
	while((match = regex.exec(this.code)) != null)
	{
		// if a match exists (there is a value for the attribute)
		if(match[1] != undefined && match[1] != '')
		{
			push(this.matches, new dp.sh.Match(match[1], match.index + match[0].indexOf(match[1]), 'strings'));

			// Add the attribute to the array of string matches
			push(this.stringMatches, match[1]);
		}
	}

	// Match string enclosed in double quoats
	while((match = dp.sh.RegexLib.DoubleQuotedString.exec(this.code)) != null)
	{
		//if (this.stringMatches.indexOf(match[0]) == -1)
		if (find(this.stringMatches, match[0]) == -1)
			push(this.matches, new dp.sh.Match(match[0], match.index, 'strings'));
	}

	// Match string enclosed in single quoats
	while((match = dp.sh.RegexLib.SingleQuotedString.exec(this.code)) != null)
	{
		//if (this.stringMatches.indexOf(match[0]) == -1)
		if (find(this.stringMatches, match[0]) == -1)
			push(this.matches, new dp.sh.Match(match[0], match.index, 'strings'));
	}
}

/**
 * Code Syntax Highlighter for C++(Windows Platform).
 * Version 0.0.2
 * Copyright (C) 2006 Shin, YoungJin.
 * http://www.jiniya.net/lecture/techbox/test.html
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

dp.sh.Brushes.Cpp = function()
{
	var datatypes =
	'ATOM BOOL BOOLEAN BYTE CHAR COLORREF DWORD DWORDLONG DWORD_PTR ' +
	'DWORD32 DWORD64 FLOAT HACCEL HALF_PTR HANDLE HBITMAP HBRUSH ' +
	'HCOLORSPACE HCONV HCONVLIST HCURSOR HDC HDDEDATA HDESK HDROP HDWP ' +
	'HENHMETAFILE HFILE HFONT HGDIOBJ HGLOBAL HHOOK HICON HINSTANCE HKEY ' +
	'HKL HLOCAL HMENU HMETAFILE HMODULE HMONITOR HPALETTE HPEN HRESULT ' +
	'HRGN HRSRC HSZ HWINSTA HWND INT INT_PTR INT32 INT64 LANGID LCID LCTYPE ' +
	'LGRPID LONG LONGLONG LONG_PTR LONG32 LONG64 LPARAM LPBOOL LPBYTE LPCOLORREF ' +
	'LPCSTR LPCTSTR LPCVOID LPCWSTR LPDWORD LPHANDLE LPINT LPLONG LPSTR LPTSTR ' +
	'LPVOID LPWORD LPWSTR LRESULT PBOOL PBOOLEAN PBYTE PCHAR PCSTR PCTSTR PCWSTR ' +
	'PDWORDLONG PDWORD_PTR PDWORD32 PDWORD64 PFLOAT PHALF_PTR PHANDLE PHKEY PINT ' +
	'PINT_PTR PINT32 PINT64 PLCID PLONG PLONGLONG PLONG_PTR PLONG32 PLONG64 POINTER_32 ' +
	'POINTER_64 PSHORT PSIZE_T PSSIZE_T PSTR PTBYTE PTCHAR PTSTR PUCHAR PUHALF_PTR ' +
	'PUINT PUINT_PTR PUINT32 PUINT64 PULONG PULONGLONG PULONG_PTR PULONG32 PULONG64 ' +
	'PUSHORT PVOID PWCHAR PWORD PWSTR SC_HANDLE SC_LOCK SERVICE_STATUS_HANDLE SHORT ' +
	'SIZE_T SSIZE_T TBYTE TCHAR UCHAR UHALF_PTR UINT UINT_PTR UINT32 UINT64 ULONG ' +
	'ULONGLONG ULONG_PTR ULONG32 ULONG64 USHORT USN VOID WCHAR WORD WPARAM WPARAM WPARAM ' +
	'char bool short int __int32 __int64 __int8 __int16 long float double __wchar_t ' +
	'clock_t _complex _dev_t _diskfree_t div_t ldiv_t _exception _EXCEPTION_POINTERS ' +
	'FILE _finddata_t _finddatai64_t _wfinddata_t _wfinddatai64_t __finddata64_t ' +
	'__wfinddata64_t _FPIEEE_RECORD fpos_t _HEAPINFO _HFILE lconv intptr_t ' +
	'jmp_buf mbstate_t _off_t _onexit_t _PNH ptrdiff_t _purecall_handler ' +
	'sig_atomic_t size_t _stat __stat64 _stati64 terminate_function ' +
	'time_t __time64_t _timeb __timeb64 tm uintptr_t _utimbuf ' +
	'va_list wchar_t wctrans_t wctype_t wint_t signed';

	var keywords =
	'break case catch class const __finally __exception __try ' +
	'const_cast continue private public protected __declspec ' +
	'default delete deprecated dllexport dllimport do dynamic_cast ' +
	'else enum explicit extern if for friend goto inline ' +
	'mutable naked namespace new noinline noreturn nothrow ' +
	'register reinterpret_cast return selectany ' +
	'sizeof static static_cast struct switch template this ' +
	'thread throw true false try typedef typeid typename union ' +
	'using uuid virtual void volatile whcar_t while';

	this.regexList = [
		{ regex: dp.sh.RegexLib.SingleLineCComments,				css: 'comment' },			// one line comments
		{ regex: dp.sh.RegexLib.MultiLineCComments,					css: 'comment' },			// multiline comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,					css: 'string' },			// strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,					css: 'string' },			// strings
		{ regex: new RegExp('^ *#.*', 'gm'),						css: 'preprocessor' },
		{ regex: new RegExp(this.GetKeywords(datatypes), 'gm'),		css: 'datatypes' },
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),		css: 'keyword' }
		];

	this.CssClass = 'dp-cpp';
	this.Style =	'.dp-cpp .datatypes { color: #2E8B57; font-weight: bold; }';
}

dp.sh.Brushes.Cpp.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Cpp.Aliases	= ['cpp', 'c', 'c++'];

dp.sh.Brushes.CSharp = function()
{
	var keywords =	'abstract as base bool break byte case catch char checked class const ' +
					'continue decimal default delegate do double else enum event explicit ' +
					'extern false finally fixed float for foreach get goto if implicit in int ' +
					'interface internal is lock long namespace new null object operator out ' +
					'override params private protected public readonly ref return sbyte sealed set ' +
					'short sizeof stackalloc static string struct switch this throw true try ' +
					'typeof uint ulong unchecked unsafe ushort using virtual void while';

	this.regexList = [
		// There's a slight problem with matching single line comments and figuring out
		// a difference between // and ///. Using lookahead and lookbehind solves the
		// problem, unfortunately JavaScript doesn't support lookbehind. So I'm at a
		// loss how to translate that regular expression to JavaScript compatible one.
//		{ regex: new RegExp('(?<!/)//(?!/).*$|(?<!/)////(?!/).*$|/\\*[^\\*]*(.)*?\\*/', 'gm'),	css: 'comment' },			// one line comments starting with anything BUT '///' and multiline comments
//		{ regex: new RegExp('(?<!/)///(?!/).*$', 'gm'),											css: 'comments' },		// XML comments starting with ///

		{ regex: dp.sh.RegexLib.SingleLineCComments,				css: 'comment' },			// one line comments
		{ regex: dp.sh.RegexLib.MultiLineCComments,					css: 'comment' },			// multiline comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,					css: 'string' },			// strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,					css: 'string' },			// strings
		{ regex: new RegExp('^\\s*#.*', 'gm'),						css: 'preprocessor' },		// preprocessor tags like #region and #endregion
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),		css: 'keyword' }			// c# keyword
		];

	this.CssClass = 'dp-c';
	this.Style = '.dp-c .vars { color: #d00; }';
}

dp.sh.Brushes.CSharp.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.CSharp.Aliases	= ['c#', 'c-sharp', 'csharp'];

dp.sh.Brushes.CSS = function()
{
	var keywords =	'ascent azimuth background-attachment background-color background-image background-position ' +
					'background-repeat background baseline bbox border-collapse border-color border-spacing border-style border-top ' +
					'border-right border-bottom border-left border-top-color border-right-color border-bottom-color border-left-color ' +
					'border-top-style border-right-style border-bottom-style border-left-style border-top-width border-right-width ' +
					'border-bottom-width border-left-width border-width border cap-height caption-side centerline clear clip color ' +
					'content counter-increment counter-reset cue-after cue-before cue cursor definition-src descent direction display ' +
					'elevation empty-cells float font-size-adjust font-family font-size font-stretch font-style font-variant font-weight font ' +
					'height letter-spacing line-height list-style-image list-style-position list-style-type list-style margin-top ' +
					'margin-right margin-bottom margin-left margin marker-offset marks mathline max-height max-width min-height min-width orphans ' +
					'outline-color outline-style outline-width outline overflow padding-top padding-right padding-bottom padding-left padding page ' +
					'page-break-after page-break-before page-break-inside pause pause-after pause-before pitch pitch-range play-during position ' +
					'quotes richness size slope src speak-header speak-numeral speak-punctuation speak speech-rate stemh stemv stress ' +
					'table-layout text-align text-decoration text-indent text-shadow text-transform unicode-bidi unicode-range units-per-em ' +
					'vertical-align visibility voice-family volume white-space widows width widths word-spacing x-height z-index';

	var values =	'above absolute all always aqua armenian attr aural auto avoid baseline behind below bidi-override black blink block blue bold bolder '+
					'both bottom braille capitalize caption center center-left center-right circle close-quote code collapse compact condensed '+
					'continuous counter counters crop cross crosshair cursive dashed decimal decimal-leading-zero default digits disc dotted double '+
					'embed embossed e-resize expanded extra-condensed extra-expanded fantasy far-left far-right fast faster fixed format fuchsia '+
					'gray green groove handheld hebrew help hidden hide high higher icon inline-table inline inset inside invert italic '+
					'justify landscape large larger left-side left leftwards level lighter lime line-through list-item local loud lower-alpha '+
					'lowercase lower-greek lower-latin lower-roman lower low ltr marker maroon medium message-box middle mix move narrower '+
					'navy ne-resize no-close-quote none no-open-quote no-repeat normal nowrap n-resize nw-resize oblique olive once open-quote outset '+
					'outside overline pointer portrait pre print projection purple red relative repeat repeat-x repeat-y rgb ridge right right-side '+
					'rightwards rtl run-in screen scroll semi-condensed semi-expanded separate se-resize show silent silver slower slow '+
					'small small-caps small-caption smaller soft solid speech spell-out square s-resize static status-bar sub super sw-resize '+
					'table-caption table-cell table-column table-column-group table-footer-group table-header-group table-row table-row-group teal '+
					'text-bottom text-top thick thin top transparent tty tv ultra-condensed ultra-expanded underline upper-alpha uppercase upper-latin '+
					'upper-roman url visible wait white wider w-resize x-fast x-high x-large x-loud x-low x-slow x-small x-soft xx-large xx-small yellow';

	var fonts =		'[mM]onospace [tT]ahoma [vV]erdana [aA]rial [hH]elvetica [sS]ans-serif [sS]erif';

	this.regexList = [
		{ regex: dp.sh.RegexLib.MultiLineCComments,						css: 'comment' },	// multiline comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,						css: 'string' },	// double quoted strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,						css: 'string' },	// single quoted strings
		{ regex: new RegExp('\\#[a-zA-Z0-9]{3,6}', 'g'),				css: 'value' },		// html colors
		{ regex: new RegExp('(-?\\d+)(\.\\d+)?(px|em|pt|\:|\%|)', 'g'),	css: 'value' },		// sizes
		{ regex: new RegExp('!important', 'g'),							css: 'important' },	// !important
		{ regex: new RegExp(this.GetKeywordsCSS(keywords), 'gm'),		css: 'keyword' },	// keywords
		{ regex: new RegExp(this.GetValuesCSS(values), 'g'),			css: 'value' },		// values
		{ regex: new RegExp(this.GetValuesCSS(fonts), 'g'),				css: 'value' }		// fonts
		];

	this.CssClass = 'dp-css';
	this.Style =	'.dp-css .value { color: black; }' +
					'.dp-css .important { color: red; }'
					;
}

dp.sh.Highlighter.prototype.GetKeywordsCSS = function(str)
{
	return '\\b([a-z_]|)' + str.replace(/ /g, '(?=:)\\b|\\b([a-z_\\*]|\\*|)') + '(?=:)\\b';
}

dp.sh.Highlighter.prototype.GetValuesCSS = function(str)
{
	return '\\b' + str.replace(/ /g, '(?!-)(?!:)\\b|\\b()') + '\:\\b';
}

dp.sh.Brushes.CSS.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.CSS.Aliases	= ['css'];

/* Delphi brush is contributed by Eddie Shipman */
dp.sh.Brushes.Delphi = function()
{
	var keywords =	'abs addr and ansichar ansistring array as asm begin boolean byte cardinal ' +
					'case char class comp const constructor currency destructor div do double ' +
					'downto else end except exports extended false file finalization finally ' +
					'for function goto if implementation in inherited int64 initialization ' +
					'integer interface is label library longint longword mod nil not object ' +
					'of on or packed pansichar pansistring pchar pcurrency pdatetime pextended ' +
					'pint64 pointer private procedure program property pshortstring pstring ' +
					'pvariant pwidechar pwidestring protected public published raise real real48 ' +
					'record repeat set shl shortint shortstring shr single smallint string then ' +
					'threadvar to true try type unit until uses val var varirnt while widechar ' +
					'widestring with word write writeln xor';

	this.regexList = [
		{ regex: new RegExp('\\(\\*[\\s\\S]*?\\*\\)', 'gm'),		css: 'comment' },  			// multiline comments (* *)
		{ regex: new RegExp('{(?!\\$)[\\s\\S]*?}', 'gm'),			css: 'comment' },  			// multiline comments { }
		{ regex: dp.sh.RegexLib.SingleLineCComments,				css: 'comment' },  			// one line
		{ regex: dp.sh.RegexLib.SingleQuotedString,					css: 'string' },			// strings
		{ regex: new RegExp('\\{\\$[a-zA-Z]+ .+\\}', 'g'),			css: 'directive' },			// Compiler Directives and Region tags
		{ regex: new RegExp('\\b[\\d\\.]+\\b', 'g'),				css: 'number' },			// numbers 12345
		{ regex: new RegExp('\\$[a-zA-Z0-9]+\\b', 'g'),				css: 'number' },			// numbers $F5D3
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),		css: 'keyword' }			// keyword
		];

	this.CssClass = 'dp-delphi';
	this.Style =	'.dp-delphi .number { color: blue; }' +
					'.dp-delphi .directive { color: #008284; }' +
					'.dp-delphi .vars { color: #000; }';
}

dp.sh.Brushes.Delphi.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Delphi.Aliases	= ['delphi', 'pascal'];

dp.sh.Brushes.Java = function()
{
	var keywords =	'abstract assert boolean break byte case catch char class const ' +
			'continue default do double else enum extends ' +
			'false final finally float for goto if implements import ' +
			'instanceof int interface long native new null ' +
			'package private protected public return ' +
			'short static strictfp super switch synchronized this throw throws true ' +
			'transient try void volatile while';

	this.regexList = [
		{ regex: dp.sh.RegexLib.SingleLineCComments,							css: 'comment' },		// one line comments
		{ regex: dp.sh.RegexLib.MultiLineCComments,								css: 'comment' },		// multiline comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,								css: 'string' },		// strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,								css: 'string' },		// strings
		{ regex: new RegExp('\\b([\\d]+(\\.[\\d]+)?|0x[a-f0-9]+)\\b', 'gi'),	css: 'number' },		// numbers
		{ regex: new RegExp('(?!\\@interface\\b)\\@[\\$\\w]+\\b', 'g'),			css: 'annotation' },	// annotation @anno
		{ regex: new RegExp('\\@interface\\b', 'g'),							css: 'keyword' },		// @interface keyword
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),					css: 'keyword' }		// java keyword
		];

	this.CssClass = 'dp-j';
	this.Style =	'.dp-j .annotation { color: #646464; }' +
					'.dp-j .number { color: #C00000; }';
}

dp.sh.Brushes.Java.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Java.Aliases	= ['java'];

dp.sh.Brushes.JScript = function()
{
	var keywords =	'abstract boolean break byte case catch char class const continue debugger ' +
					'default delete do double else enum export extends false final finally float ' +
					'for function goto if implements import in instanceof int interface long native ' +
					'new null package private protected public return short static super switch ' +
					'synchronized this throw throws transient true try typeof var void volatile while with';

	this.regexList = [
		{ regex: dp.sh.RegexLib.SingleLineCComments,				css: 'comment' },			// one line comments
		{ regex: dp.sh.RegexLib.MultiLineCComments,					css: 'comment' },			// multiline comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,					css: 'string' },			// double quoted strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,					css: 'string' },			// single quoted strings
		{ regex: new RegExp('^\\s*#.*', 'gm'),						css: 'preprocessor' },		// preprocessor tags like #region and #endregion
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),		css: 'keyword' }			// keywords
		];

	this.CssClass = 'dp-c';
}

dp.sh.Brushes.JScript.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.JScript.Aliases	= ['js', 'jscript', 'javascript'];

dp.sh.Brushes.Lua = function()
{
	var keywords =	'break do end else elseif function if local nil not or repeat return and then until while this';
	var funcs = 'math\\.\\w+ string\\.\\w+ os\\.\\w+ debug\\.\\w+ io\\.\\w+ error fopen dofile coroutine\\.\\w+ arg getmetatable ipairs loadfile loadlib loadstring longjmp print rawget rawset seek setmetatable assert tonumber tostring';

	this.regexList = [
		{ regex: new RegExp('--\\[\\[[\\s\\S]*\\]\\]--', 'gm'),		css: 'comment'},
		{ regex: new RegExp('--[^\\[]{2}.*$', 'gm'),			css: 'comment' },			// one line comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,			css: 'string' },	// strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,			css: 'string' },	// strings
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),		css: 'keyword' },			// keyword
		{ regex: new RegExp(this.GetKeywords(funcs), 'gm'),		css: 'func' },			// functions
		];

	this.CssClass = 'dp-lua';
}

dp.sh.Brushes.Lua.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Lua.Aliases	= ['lua'];

dp.sh.Brushes.Mxml = function()
{
	this.CssClass = 'dp-mxml';
	this.Style =	'.dp-mxml .cdata { color: #000000; }' +
					'.dp-mxml .tag { color : #0000ff; }' +
					'.dp-mxml .tag-name { color: #0000ff; }' +
					'.dp-mxml .script { color: green; }' +
					'.dp-mxml .metadata { color: green; }' +
					'.dp-mxml .attribute { color: #000000; }' +
					'.dp-mxml .attribute-value { color: #990000; }' +
					'.dp-mxml .trace { color: #cc6666; }' +
					'.dp-mxml .var { color: #6699cc; }' +
					'.dp-mxml .comment { color: #009900; }' +
					'.dp-mxml .string { color: #990000; }' +
					'.dp-mxml .keyword { color: blue; }';
}

dp.sh.Brushes.Mxml.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Mxml.Aliases	= ['mxml'];

dp.sh.Brushes.Mxml.prototype.ProcessRegexList = function()
{
	function push(array, value)
	{
		array[array.length] = value;
	}

	function isInScriptTag(array, match)
	{
		var i = 0;
		var inScript = false;
		for(i = 0; i < array.length; i++){
			if(match.index > array[i].firstIndex && match.index < array[i].lastIndex){
				inScript = true;
			}
		}
		return inScript;
	}

	/* If only there was a way to get index of a group within a match, the whole XML
	   could be matched with the expression looking something like that:

	   (<!\[CDATA\[\s*.*\s*\]\]>)
	   | (<!--\s*.*\s*?-->)
	   | (<)*(\w+)*\s*(\w+)\s*=\s*(".*?"|'.*?'|\w+)(/*>)*
	   | (</?)(.*?)(/?>)
	*/
	var index	= 0;
	var match	= null;
	var asmatch	= null;
	var regex	= null;
	var target = "";
	var scriptTags = new Array();

	var keywords =	'abstract boolean break byte case catch char class const continue debugger ' +
					'default delete do double else enum export extends false final finally float ' +
					'for function goto if implements import in instanceof int interface long native ' +
					'new null package private protected public return short static super switch ' +
					'synchronized this throw throws transient true try typeof var void volatile while with';
	var regexList = [
		{ regex: dp.sh.RegexLib.SingleLineCComments,				css: 'comment' },			// one line comments
		{ regex: dp.sh.RegexLib.MultiLineCComments,					css: 'comment' },			// multiline comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,					css: 'string' },			// double quoted strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,					css: 'string' },			// single quoted strings
		{ regex: new RegExp('^\\s*#.*', 'gm'),						css: 'preprocessor' },		// preprocessor tags like #region and #endregion
		{ regex: new RegExp(this.GetKeywords("trace"), 'gm'),		css: 'trace' },			// keywords
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),		css: 'keyword' }			// keywords
		];

	// Match CDATA in the following format <![ ... [ ... ]]>
	// (\&lt;|<)\!\[[\w\s]*?\[(.|\s)*?\]\](\&gt;|>)
	//this.GetMatches(new RegExp('(\&lt;|<)\\!\\[[\\w\\s]*?\\[(.|\\s)*?\\]\\](\&gt;|>)', 'gm'), 'cdata');
	regex = new RegExp('\&lt;\\!\\[CDATA\\[(.|\\s)*?\\]\\]\&gt;', 'gm');
	while((match = regex.exec(this.code)) != null)
	{
		// <![CDATA[
		target = match[0].substr(0,12);
		push(this.matches, new dp.sh.Match(target, match.index, 'cdata'));

		// code
		target = match[0].substr(12,match[0].length-12-6);
		for(var i = 0; i < regexList.length; i++)
			while((asmatch = regexList[i].regex.exec(target)) != null)
				push(this.matches, new dp.sh.Match(asmatch[0], match.index + 12 + asmatch.index, regexList[i].css));

		// ]]>
		target = match[0].substr(match[0].length-6,6);
		push(this.matches, new dp.sh.Match(target, match.index + match[0].length-6, 'cdata'));

		scriptTags.push({firstIndex: match.index, lastIndex: match.index + match[0].length-1});
	}

	// Match comments
	// (\&lt;|<)!--\s*.*?\s*--(\&gt;|>)
	this.GetMatches(new RegExp('(\&lt;|<)!--\\s*.*?\\s*--(\&gt;|>)', 'gm'), 'comments');

	// Match attributes and their values
	// (:|\w+)\s*=\s*(".*?"|\'.*?\'|\w+)*
	regex = new RegExp('([:\\w-\.]+)\\s*=\\s*(".*?"|\'.*?\'|\\w+)*|(\\w+)', 'gm'); // Thanks to Tomi Blinnikka of Yahoo! for fixing namespaces in attributes
	while((match = regex.exec(this.code)) != null)
	{
		if(match[1] == null)
		{
			continue;
		}

		if(isInScriptTag(scriptTags, match)){
			continue;
		}

		push(this.matches, new dp.sh.Match(match[1], match.index, 'attribute'));

		// if xml is invalid and attribute has no property value, ignore it
		if(match[2] != undefined)
		{
			push(this.matches, new dp.sh.Match(match[2], match.index + match[0].indexOf(match[2]), 'attribute-value'));
		}
	}

	// Match tag names
	// (\&lt;|<)/*\?*\s*(\w+)
	regex = new RegExp('(?:\&lt;|<)/*\\?*\\s*([:\\w-\.]+)', 'gm');
	while((match = regex.exec(this.code)) != null)
	{
		if(isInScriptTag(scriptTags, match)){
			continue;
		}

		target = match[0].substr(4,match[0].length-4);
		switch(target){
			case "mx:Script":
			case "/mx:Script":
				push(this.matches, new dp.sh.Match(match[0]+"&gt;", match.index, 'script'));
				break;
			case "mx:Metadata":
			case "/mx:Metadata":
				push(this.matches, new dp.sh.Match(match[0]+"&gt;", match.index, 'metadata'));
				break;
			default :
				push(this.matches, new dp.sh.Match(match[0], match.index, 'tag-name'));
				break;
		}
	}

	// Match opening and closing tag brackets
	// (\&lt;|<)/*\?*(?!\!)|/*\?*(\&gt;|>)
	regex = new RegExp('\\?&gt;|\&gt;|\/\&gt;', 'gm');
	while((match = regex.exec(this.code)) != null)
	{
		if(isInScriptTag(scriptTags, match)){
			continue;
		}
		push(this.matches, new dp.sh.Match(match[0], match.index, 'tag'));
	}
}

dp.sh.Brushes.Perl = function()
{
	var funcs = 'abs accept alarm atan2 bind binmode bless caller chdir chmod chomp chop chown chr chroot close closedir connect cos crypt dbmclose dbmopen defined delete dump each endgrent endhostent endnetent endprotoent endpwent endservent eof exec exists exp fcntl fileno flock fork format formline getc getgrent getgrgid getgrnam gethostbyaddr gethostbyname gethostent getlogin getnetbyaddr getnetbyname getnetent getpeername getpgrp getppid getpriority getprotobyname getprotobynumber getprotoent getpwent getpwnam getpwuid getservbyname getservbyport getservent getsockname getsockopt glob gmtime grep hex import index int ioctl join keys kill lc lcfirst length link listen localtime lock log lstat m map mkdir msgctl msgget msgrcv msgsnd no oct open opendir ord pack pipe pop pos print printf prototype push q qq quotemeta qw qx rand read readdir readline readlink readpipe recv ref rename reset reverse rewinddir rindex rmdir scalar seek seekdir semctl semget semop send setgrent sethostent setnetent setpgrp setpriority setprotoent setpwent setservent setsockopt shift shmctl shmget shmread shmwrite shutdown sin sleep socket socketpair sort splice split sprintf sqrt srand stat study sub substr symlink syscall sysopen sysread sysseek system syswrite tell telldir tie tied time times tr truncate uc ucfirst umask undef unlink unpack unshift untie utime values vec waitpid wantarray warn write qr';

	var keywords =	's select goto die do package redo require return continue for foreach last next wait while use if else elsif eval exit unless switch case';

	var declarations = 'my our local';

	this.regexList = [
		{ regex: dp.sh.RegexLib.SingleLinePerlComments, css: 'comment' },			// one line comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString, css: 'string' },				// double quoted strings
		{ regex: dp.sh.RegexLib.SingleQuotedString, css: 'string' },				// single quoted strings
		{ regex: new RegExp('(\\$|@|%)\\w+', 'g'), css: 'vars' },				// variables
		{ regex: new RegExp(this.GetKeywords(funcs), 'gmi'), css: 'func' },			// functions
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'), css: 'keyword' },			// keyword
		{ regex: new RegExp(this.GetKeywords(declarations), 'gm'), css: 'declarations' }	// declarations
	];

	this.CssClass = 'dp-perl';
}

dp.sh.Brushes.Perl.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Perl.Aliases	= ['perl'];

dp.sh.Brushes.Php = function()
{
	var funcs	=	'abs acos acosh addcslashes addslashes ' +
					'array_change_key_case array_chunk array_combine array_count_values array_diff '+
					'array_diff_assoc array_diff_key array_diff_uassoc array_diff_ukey array_fill '+
					'array_filter array_flip array_intersect array_intersect_assoc array_intersect_key '+
					'array_intersect_uassoc array_intersect_ukey array_key_exists array_keys array_map '+
					'array_merge array_merge_recursive array_multisort array_pad array_pop array_product '+
					'array_push array_rand array_reduce array_reverse array_search array_shift '+
					'array_slice array_splice array_sum array_udiff array_udiff_assoc '+
					'array_udiff_uassoc array_uintersect array_uintersect_assoc '+
					'array_uintersect_uassoc array_unique array_unshift array_values array_walk '+
					'array_walk_recursive atan atan2 atanh base64_decode base64_encode base_convert '+
					'basename bcadd bccomp bcdiv bcmod bcmul bindec bindtextdomain bzclose bzcompress '+
					'bzdecompress bzerrno bzerror bzerrstr bzflush bzopen bzread bzwrite ceil chdir '+
					'checkdate checkdnsrr chgrp chmod chop chown chr chroot chunk_split class_exists '+
					'closedir closelog copy cos cosh count count_chars date decbin dechex decoct '+
					'deg2rad delete ebcdic2ascii echo empty end ereg ereg_replace eregi eregi_replace error_log '+
					'error_reporting escapeshellarg escapeshellcmd eval exec exit exp explode extension_loaded '+
					'feof fflush fgetc fgetcsv fgets fgetss file_exists file_get_contents file_put_contents '+
					'fileatime filectime filegroup fileinode filemtime fileowner fileperms filesize filetype '+
					'floatval flock floor flush fmod fnmatch fopen fpassthru fprintf fputcsv fputs fread fscanf '+
					'fseek fsockopen fstat ftell ftok getallheaders getcwd getdate getenv gethostbyaddr gethostbyname '+
					'gethostbynamel getimagesize getlastmod getmxrr getmygid getmyinode getmypid getmyuid getopt '+
					'getprotobyname getprotobynumber getrandmax getrusage getservbyname getservbyport gettext '+
					'gettimeofday gettype glob gmdate gmmktime ini_alter ini_get ini_get_all ini_restore ini_set '+
					'interface_exists intval ip2long is_a is_array is_bool is_callable is_dir is_double '+
					'is_executable is_file is_finite is_float is_infinite is_int is_integer is_link is_long '+
					'is_nan is_null is_numeric is_object is_readable is_real is_resource is_scalar is_soap_fault '+
					'is_string is_subclass_of is_uploaded_file is_writable is_writeable mkdir mktime nl2br '+
					'parse_ini_file parse_str parse_url passthru pathinfo readlink realpath rewind rewinddir rmdir '+
					'round str_ireplace str_pad str_repeat str_replace str_rot13 str_shuffle str_split '+
					'str_word_count strcasecmp strchr strcmp strcoll strcspn strftime strip_tags stripcslashes '+
					'stripos stripslashes stristr strlen strnatcasecmp strnatcmp strncasecmp strncmp strpbrk '+
					'strpos strptime strrchr strrev strripos strrpos strspn strstr strtok strtolower strtotime '+
					'strtoupper strtr strval substr substr_compare';

	var keywords =	'and or xor __FILE__ __LINE__ array as break case ' +
					'cfunction class const continue declare default die do else ' +
					'elseif empty enddeclare endfor endforeach endif endswitch endwhile ' +
					'extends for foreach function include include_once global if ' +
					'new old_function return static switch use require require_once ' +
					'var while __FUNCTION__ __CLASS__ ' +
					'__METHOD__ abstract interface public implements extends private protected throw';

	this.regexList = [
		{ regex: dp.sh.RegexLib.SingleLineCComments,				css: 'comment' },			// one line comments
		{ regex: dp.sh.RegexLib.MultiLineCComments,					css: 'comment' },			// multiline comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,					css: 'string' },			// double quoted strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,					css: 'string' },			// single quoted strings
		{ regex: new RegExp('\\$\\w+', 'g'),						css: 'vars' },				// variables
		{ regex: new RegExp(this.GetKeywords(funcs), 'gmi'),		css: 'func' },				// functions
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),		css: 'keyword' }			// keyword
		];

	this.CssClass = 'dp-c';
}

dp.sh.Brushes.Php.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Php.Aliases	= ['php'];

/* Python 2.3 syntax contributed by Gheorghe Milas */
dp.sh.Brushes.Python = function()
{
    var keywords =  'and assert break class continue def del elif else ' +
                    'except exec finally for from global if import in is ' +
                    'lambda not or pass print raise return try yield while';

    var special =  'None True False self cls class_'

    this.regexList = [
        { regex: dp.sh.RegexLib.SingleLinePerlComments, css: 'comment' },
        { regex: new RegExp("^\\s*@\\w+", 'gm'), css: 'decorator' },
        { regex: new RegExp("(['\"]{3})([^\\1])*?\\1", 'gm'), css: 'comment' },
        { regex: new RegExp('"(?!")(?:\\.|\\\\\\"|[^\\""\\n\\r])*"', 'gm'), css: 'string' },
        { regex: new RegExp("'(?!')*(?:\\.|(\\\\\\')|[^\\''\\n\\r])*'", 'gm'), css: 'string' },
        { regex: new RegExp("\\b\\d+\\.?\\w*", 'g'), css: 'number' },
        { regex: new RegExp(this.GetKeywords(keywords), 'gm'), css: 'keyword' },
        { regex: new RegExp(this.GetKeywords(special), 'gm'), css: 'special' }
        ];

    this.CssClass = 'dp-py';
	this.Style =	'.dp-py .builtins { color: #ff1493; }' +
					'.dp-py .magicmethods { color: #808080; }' +
					'.dp-py .exceptions { color: brown; }' +
					'.dp-py .types { color: brown; font-style: italic; }' +
					'.dp-py .commonlibs { color: #8A2BE2; font-style: italic; }';
}

dp.sh.Brushes.Python.prototype  = new dp.sh.Highlighter();
dp.sh.Brushes.Python.Aliases    = ['py', 'python'];

/* Ruby 1.8.4 syntax contributed by Erik Peterson */
dp.sh.Brushes.Ruby = function()
{
  var keywords =	'alias and BEGIN begin break case class def define_method defined do each else elsif ' +
					'END end ensure false for if in module new next nil not or raise redo rescue retry return ' +
					'self super then throw true undef unless until when while yield';

  var builtins =	'Array Bignum Binding Class Continuation Dir Exception FalseClass File::Stat File Fixnum Fload ' +
					'Hash Integer IO MatchData Method Module NilClass Numeric Object Proc Range Regexp String Struct::TMS Symbol ' +
					'ThreadGroup Thread Time TrueClass'

	this.regexList = [
		{ regex: dp.sh.RegexLib.SingleLinePerlComments,			css: 'comment' },	// one line comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,				css: 'string' },	// double quoted strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,				css: 'string' },	// single quoted strings
		{ regex: new RegExp(':[a-z][A-Za-z0-9_]*', 'g'),		css: 'symbol' },	// symbols
		{ regex: new RegExp('(\\$|@@|@)\\w+', 'g'),				css: 'variable' },	// $global, @instance, and @@class variables
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),	css: 'keyword' },	// keywords
		{ regex: new RegExp(this.GetKeywords(builtins), 'gm'),	css: 'builtin' }	// builtins
		];

	this.CssClass = 'dp-rb';
	this.Style =	'.dp-rb .symbol { color: #a70; }' +
					'.dp-rb .variable { color: #a70; font-weight: bold; }';
}

dp.sh.Brushes.Ruby.prototype = new dp.sh.Highlighter();
dp.sh.Brushes.Ruby.Aliases = ['ruby', 'rails', 'ror'];

dp.sh.Brushes.Sql = function()
{
	var funcs	=	'abs avg case cast coalesce convert count current_timestamp ' +
					'current_user day isnull left lower month nullif replace right ' +
					'session_user space substring sum system_user upper user year';

	var keywords =	'absolute action add after alter as asc at authorization begin bigint ' +
					'binary bit by cascade char character check checkpoint close collate ' +
					'column commit committed connect connection constraint contains continue ' +
					'create cube current current_date current_time cursor database date ' +
					'deallocate dec decimal declare default delete desc distinct double drop ' +
					'dynamic else end end-exec escape except exec execute false fetch first ' +
					'float for force foreign forward free from full function global goto grant ' +
					'group grouping having hour ignore index inner insensitive insert instead ' +
					'int integer intersect into is isolation key last level load local max min ' +
					'minute modify move name national nchar next no numeric of off on only ' +
					'open option order out output partial password precision prepare primary ' +
					'prior privileges procedure public read real references relative repeatable ' +
					'restrict return returns revoke rollback rollup rows rule schema scroll ' +
					'second section select sequence serializable set size smallint static ' +
					'statistics table temp temporary then time timestamp to top transaction ' +
					'translation trigger true truncate uncommitted union unique update values ' +
					'varchar varying view when where with work';

	var operators =	'all and any between cross in join like not null or outer some';

	this.regexList = [
		{ regex: new RegExp('--(.*)$', 'gm'),						css: 'comment' },			// one line and multiline comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,					css: 'string' },			// double quoted strings
		{ regex: dp.sh.RegexLib.SingleQuotedString,					css: 'string' },			// single quoted strings
		{ regex: new RegExp(this.GetKeywords(funcs), 'gmi'),		css: 'func' },				// functions
		{ regex: new RegExp(this.GetKeywords(operators), 'gmi'),	css: 'op' },				// operators and such
		{ regex: new RegExp(this.GetKeywords(keywords), 'gmi'),		css: 'keyword' }			// keyword
		];

	this.CssClass = 'dp-sql';
	this.Style =	'.dp-sql .func { color: #ff1493; }' +
					'.dp-sql .op { color: #808080; }';
}

dp.sh.Brushes.Sql.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Sql.Aliases	= ['sql'];

dp.sh.Brushes.Vb = function()
{
	var keywords =	'AddHandler AddressOf AndAlso Alias And Ansi As Assembly Auto ' +
					'Boolean ByRef Byte ByVal Call Case Catch CBool CByte CChar CDate ' +
					'CDec CDbl Char CInt Class CLng CObj Const CShort CSng CStr CType ' +
					'Date Decimal Declare Default Delegate Dim DirectCast Do Double Each ' +
					'Else ElseIf End Enum Erase Error Event Exit False Finally For Friend ' +
					'Function Get GetType GoSub GoTo Handles If Implements Imports In ' +
					'Inherits Integer Interface Is Let Lib Like Long Loop Me Mod Module ' +
					'MustInherit MustOverride MyBase MyClass Namespace New Next Not Nothing ' +
					'NotInheritable NotOverridable Object On Option Optional Or OrElse ' +
					'Overloads Overridable Overrides ParamArray Preserve Private Property ' +
					'Protected Public RaiseEvent ReadOnly ReDim REM RemoveHandler Resume ' +
					'Return Select Set Shadows Shared Short Single Static Step Stop String ' +
					'Structure Sub SyncLock Then Throw To True Try TypeOf Unicode Until ' +
					'Variant When While With WithEvents WriteOnly Xor';

	this.regexList = [
		{ regex: new RegExp('\'.*$', 'gm'),							css: 'comment' },			// one line comments
		{ regex: dp.sh.RegexLib.DoubleQuotedString,					css: 'string' },			// strings
		{ regex: new RegExp('^\\s*#.*', 'gm'),						css: 'preprocessor' },		// preprocessor tags like #region and #endregion
		{ regex: new RegExp(this.GetKeywords(keywords), 'gm'),		css: 'keyword' }			// c# keyword
		];

	this.CssClass = 'dp-vb';
}

dp.sh.Brushes.Vb.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Vb.Aliases	= ['vb', 'vb.net'];

dp.sh.Brushes.Xml = function()
{
	this.CssClass = 'dp-xml';
	this.Style =	'.dp-xml .cdata { color: #ff1493; }' +
					'.dp-xml .tag, .dp-xml .tag-name { color: #069; font-weight: bold; }' +
					'.dp-xml .attribute { color: red; }' +
					'.dp-xml .attribute-value { color: blue; }';
}

dp.sh.Brushes.Xml.prototype	= new dp.sh.Highlighter();
dp.sh.Brushes.Xml.Aliases	= ['xml', 'xhtml', 'xslt', 'html', 'xhtml'];

dp.sh.Brushes.Xml.prototype.ProcessRegexList = function()
{
	function push(array, value)
	{
		array[array.length] = value;
	}

	/* If only there was a way to get index of a group within a match, the whole XML
	   could be matched with the expression looking something like that:

	   (<!\[CDATA\[\s*.*\s*\]\]>)
	   | (<!--\s*.*\s*?-->)
	   | (<)*(\w+)*\s*(\w+)\s*=\s*(".*?"|'.*?'|\w+)(/*>)*
	   | (</?)(.*?)(/?>)
	*/
	var index	= 0;
	var match	= null;
	var regex	= null;

	// Match CDATA in the following format <![ ... [ ... ]]>
	// (\&lt;|<)\!\[[\w\s]*?\[(.|\s)*?\]\](\&gt;|>)
	this.GetMatches(new RegExp('(\&lt;|<)\\!\\[[\\w\\s]*?\\[(.|\\s)*?\\]\\](\&gt;|>)', 'gm'), 'cdata');

	// Match comments
	// (\&lt;|<)!--\s*.*?\s*--(\&gt;|>)
	this.GetMatches(new RegExp('(\&lt;|<)!--\\s*.*?\\s*--(\&gt;|>)', 'gm'), 'comments');

	// Match attributes and their values
	// (:|\w+)\s*=\s*(".*?"|\'.*?\'|\w+)*
	regex = new RegExp('([:\\w-\.]+)\\s*=\\s*(".*?"|\'.*?\'|\\w+)*|(\\w+)', 'gm'); // Thanks to Tomi Blinnikka of Yahoo! for fixing namespaces in attributes
	while((match = regex.exec(this.code)) != null)
	{
		if(match[1] == null)
		{
			continue;
		}

		push(this.matches, new dp.sh.Match(match[1], match.index, 'attribute'));

		// if xml is invalid and attribute has no property value, ignore it
		if(match[2] != undefined)
		{
			push(this.matches, new dp.sh.Match(match[2], match.index + match[0].indexOf(match[2]), 'attribute-value'));
		}
	}

	// Match opening and closing tag brackets
	// (\&lt;|<)/*\?*(?!\!)|/*\?*(\&gt;|>)
	this.GetMatches(new RegExp('(\&lt;|<)/*\\?*(?!\\!)|/*\\?*(\&gt;|>)', 'gm'), 'tag');

	// Match tag names
	// (\&lt;|<)/*\?*\s*(\w+)
	regex = new RegExp('(?:\&lt;|<)/*\\?*\\s*([:\\w-\.]+)', 'gm');
	while((match = regex.exec(this.code)) != null)
	{
		push(this.matches, new dp.sh.Match(match[1], match.index + match[0].indexOf(match[1]), 'tag-name'));
	}
}

/*****************************************************************************************************************/

//{{{
version.extensions.SinglePageModePlugin= {major: 2, minor: 9, revision: 5, date: new Date(2008,6,12)};

config.paramifiers.SPM = { onstart: function(v) {
	config.options.chkSinglePageMode=eval(v);
	if (config.options.chkSinglePageMode && config.options.chkSinglePagePermalink && !config.browser.isSafari) {
		config.lastURL = window.location.hash;
		if (!config.SPMTimer) config.SPMTimer=window.setInterval(function() {checkLastURL();},1000);
	}
} };

config.options.chkSinglePageMode=true;
config.options.chkSinglePagePermalink=true;
config.options.chkSinglePageKeepFoldedTiddlers=false;
config.options.chkSinglePageKeepEditedTiddlers=false;
config.options.chkTopOfPageMode=false;
config.options.chkBottomOfPageMode=false;
config.options.chkSinglePageAutoScroll=true;

config.SPMTimer = 0;
config.lastURL = window.location.hash;
function checkLastURL()
{
	if (!config.options.chkSinglePageMode)
		{ window.clearInterval(config.SPMTimer); config.SPMTimer=0; return; }
	if (config.lastURL == window.location.hash) return; // no change in hash
	var tids=decodeURIComponent(window.location.hash.substr(1)).readBracketedList();
	if (tids.length==1) // permalink (single tiddler in URL)
		story.displayTiddler(null,tids[0]);
	else { // restore permaview or default view
		config.lastURL = window.location.hash;
		if (!tids.length) tids=store.getTiddlerText("DefaultTiddlers").readBracketedList();
		story.closeAllTiddlers();
		story.displayTiddlers(null,tids);
	}
}

if (Story.prototype.SPM_coreDisplayTiddler==undefined)
	Story.prototype.SPM_coreDisplayTiddler=Story.prototype.displayTiddler;
Story.prototype.displayTiddler = function(srcElement,tiddler,template,animate,slowly)
{
	var title=(tiddler instanceof Tiddler)?tiddler.title:tiddler;
	var tiddlerElem=document.getElementById(story.idPrefix+title); // ==null unless tiddler is already displayed
	var opt=config.options;
	var single=opt.chkSinglePageMode && !startingUp;
	var top=opt.chkTopOfPageMode && !startingUp;
	var bottom=opt.chkBottomOfPageMode && !startingUp;
	if (single) {
		story.forEachTiddler(function(tid,elem) {
			// skip current tiddler and, optionally, tiddlers that are folded.
			if (	tid==title
				|| (opt.chkSinglePageKeepFoldedTiddlers && elem.getAttribute("folded")=="true"))
				return;
			// if a tiddler is being edited, ask before closing
			if (elem.getAttribute("dirty")=="true") {
				if (opt.chkSinglePageKeepEditedTiddlers) return;
				// if tiddler to be displayed is already shown, then leave active tiddler editor as is
				// (occurs when switching between view and edit modes)
				if (tiddlerElem) return;
				// otherwise, ask for permission
				var msg="'"+tid+"' is currently being edited.\n\n";
				msg+="Press OK to save and close this tiddler\nor press Cancel to leave it opened";
				if (!confirm(msg)) return; else story.saveTiddler(tid);
			}
			story.closeTiddler(tid);
		});
	}
	else if (top)
		arguments[0]=null;
	else if (bottom)
		arguments[0]="bottom";
	if (single && opt.chkSinglePagePermalink && !config.browser.isSafari) {
		window.location.hash = encodeURIComponent(String.encodeTiddlyLink(title));
		config.lastURL = window.location.hash;
		document.title = wikifyPlain("SiteTitle") + " - " + title;
		if (!config.SPMTimer) config.SPMTimer=window.setInterval(function() {checkLastURL();},1000);
	}
	if (tiddlerElem && tiddlerElem.getAttribute("dirty")=="true") { // editing... move tiddler without re-rendering
		var isTopTiddler=(tiddlerElem.previousSibling==null);
		if (!isTopTiddler && (single || top))
			tiddlerElem.parentNode.insertBefore(tiddlerElem,tiddlerElem.parentNode.firstChild);
		else if (bottom)
			tiddlerElem.parentNode.insertBefore(tiddlerElem,null);
		else this.SPM_coreDisplayTiddler.apply(this,arguments); // let CORE render tiddler
	} else
		this.SPM_coreDisplayTiddler.apply(this,arguments); // let CORE render tiddler
	var tiddlerElem=document.getElementById(story.idPrefix+title);
	if (tiddlerElem&&opt.chkSinglePageAutoScroll) {
		// scroll to top of page or top of tiddler
		var isTopTiddler=(tiddlerElem.previousSibling==null);
		var yPos=isTopTiddler?0:ensureVisible(tiddlerElem);
		// if animating, defer scroll until 200ms after animation completes
		var delay=opt.chkAnimate?config.animDuration+200:0;
		setTimeout("window.scrollTo(0,"+yPos+")",delay);
	}
}

if (Story.prototype.SPM_coreDisplayTiddlers==undefined)
	Story.prototype.SPM_coreDisplayTiddlers=Story.prototype.displayTiddlers;
Story.prototype.displayTiddlers = function() {
	// suspend single/top/bottom modes when showing multiple tiddlers
	var opt=config.options;
	var saveSPM=opt.chkSinglePageMode; opt.chkSinglePageMode=false;
	var saveTPM=opt.chkTopOfPageMode; opt.chkTopOfPageMode=false;
	var saveBPM=opt.chkBottomOfPageMode; opt.chkBottomOfPageMode=false;
	this.SPM_coreDisplayTiddlers.apply(this,arguments);
	opt.chkBottomOfPageMode=saveBPM;
	opt.chkTopOfPageMode=saveTPM;
	opt.chkSinglePageMode=saveSPM;
}
//}}}

/**********************************************************************************************************/

//{{{
version.extensions.InlineJavascriptPlugin= {major: 1, minor: 9, revision: 3, date: new Date(2008,6,11)};

config.formatters.push( {
	name: "inlineJavascript",
	match: "\\<script",
	lookahead: "\\<script(?: src=\\\"((?:.|\\n)*?)\\\")?(?: label=\\\"((?:.|\\n)*?)\\\")?(?: title=\\\"((?:.|\\n)*?)\\\")?(?: key=\\\"((?:.|\\n)*?)\\\")?( show)?\\>((?:.|\\n)*?)\\</script\\>",

	handler: function(w) {
		var lookaheadRegExp = new RegExp(this.lookahead,"mg");
		lookaheadRegExp.lastIndex = w.matchStart;
		var lookaheadMatch = lookaheadRegExp.exec(w.source)
		if(lookaheadMatch && lookaheadMatch.index == w.matchStart) {
			var src=lookaheadMatch[1];
			var label=lookaheadMatch[2];
			var tip=lookaheadMatch[3];
			var key=lookaheadMatch[4];
			var show=lookaheadMatch[5];
			var code=lookaheadMatch[6];
			if (src) { // load a script library
				// make script tag, set src, add to body to execute, then remove for cleanup
				var script = document.createElement("script"); script.src = src;
				document.body.appendChild(script); document.body.removeChild(script);
			}
			if (code) { // there is script code
				if (show) // show inline script code in tiddler output
					wikify("{{{\n"+lookaheadMatch[0]+"\n}}}\n",w.output);
				if (label) { // create a link to an 'onclick' script
					// add a link, define click handler, save code in link (pass 'place'), set link attributes
					var link=createTiddlyElement(w.output,"a",null,"tiddlyLinkExisting",wikifyPlainText(label));
					var fixup=code.replace(/document.write\s*\(/gi,'place.bufferedHTML+=(');
					link.code="function _out(place){"+fixup+"\n};_out(this);"
					link.tiddler=w.tiddler;
					link.onclick=function(){
						this.bufferedHTML="";
						try{ var r=eval(this.code);
							if(this.bufferedHTML.length || (typeof(r)==="string")&&r.length)
								var s=this.parentNode.insertBefore(document.createElement("span"),this.nextSibling);
							if(this.bufferedHTML.length)
								s.innerHTML=this.bufferedHTML;
							if((typeof(r)==="string")&&r.length) {
								wikify(r,s,null,this.tiddler);
								return false;
							} else return r!==undefined?r:false;
						} catch(e){alert(e.description||e.toString());return false;}
					};
					link.setAttribute("title",tip||"");
					var URIcode='javascript:void(eval(decodeURIComponent(%22(function(){try{';
					URIcode+=encodeURIComponent(encodeURIComponent(code.replace(/\n/g,' ')));
					URIcode+='}catch(e){alert(e.description||e.toString())}})()%22)))';
					link.setAttribute("href",URIcode);
					link.style.cursor="pointer";
					if (key) link.accessKey=key.substr(0,1); // single character only
				}
				else { // run inline script code
					var fixup=code.replace(/document.write\s*\(/gi,'place.innerHTML+=(');
					var code="function _out(place){"+fixup+"\n};_out(w.output);"
					try { var out=eval(code); } catch(e) { out=e.description?e.description:e.toString(); }
					if (out && out.length) wikify(out,w.output,w.highlightRegExp,w.tiddler);
				}
			}
			w.nextMatch = lookaheadMatch.index + lookaheadMatch[0].length;
		}
	}
} )
//}}}

/**********************************************************************************************************/
//{{{
version.extensions.InlineJavascriptPlugin= {major: 1, minor: 0, revision: 1, date: new Date(2008,10,14)};

config.macros.HideSidebarOnServer = {
    init: function() {
        if (readOnly) {
            document.getElementById('displayArea').style.marginRight = '1em';
            document.getElementById('sidebar').style.display = 'none';
        }
    }
}
//}}}

/**********************************************************************************************************/
//{{{
version.extensions.displayAreaMinHeightPlugin= {major: 1, minor: 0, revision: 1, date: new Date(2008,10,15)};

config.macros.displayAreaMinHeight = {
    init: function() {
        var minHeight = '500px';
        if (config.browser.isIE && parseInt(config.browser.ieVersion[1]) <= 6) {
            document.getElementById('displayArea').style.height = minHeight;
        }
        else {
            document.getElementById('displayArea').style.minHeight = minHeight;
        }
    }
}
//}}}