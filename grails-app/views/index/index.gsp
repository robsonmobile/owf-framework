<!DOCTYPE html>
<%@ page contentType="text/html; UTF-8" %>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title id='title'>Ozone Widget Framework</title>

        <link rel="shortcut icon" href="images/favicon.ico" />
        <script language="javascript">
            //console.time('page');
        </script>
        <!-- ** CSS ** -->
        <p:css id='theme' name='${owfCss.defaultCssPath()}' absolute='true'/>
        <p:css id="bootstrap" name="${owfCss.bootstrapCssPath()}" absolute='true'/>

        <!-- initialize ozone configuration from server -->
        <owfImport:jsOwf path="config" resource="config" />

        <!-- modernizr-->
        <script src="./js-lib/modernizr/modernizr-2.6.2.js"></script>
        <!-- turn off Modernizr-based animations if needed -->
        <script>
            // limit the scope
            ;(function(Ozone, Modernizr) {
                // no animations?
                if (!Ozone.config.showAnimations) {
                    // turn off Modernizr-based animations
                    Modernizr.csstransitions = false;
                    Modernizr.cssanimations = false;
                }
            })(Ozone, Modernizr);
        </script>

        <!-- include our server bundle, in dev mode a full list of js includes will appear -->
        <p:javascript src='owf-server'/>
        <!-- include our server bundle, in dev mode a full list of js includes will appear -->

        <!-- turn off CSS- and jQuery-based animations if needed -->
        <script>
            // limit the scope
            ;(function(Ozone, Ext, jQuery) {
                // no animations?
                if (!Ozone.config.showAnimations) {
                    // turn off CSS-based animations
                    var turnOffTransitionsAndAnimationsCss =
                        '* {' +
                            '-webkit-transition:    none !important;' + // Chrome, Safari
                            '-moz-transition:       none !important;' + // Firefox
                            '-ms-transition:        none !important;' + // IE
                            '-o-transition:         none !important;' + // Opera
                            'transition:            none !important;' + // CSS 3
                            '-webkit-animation:     none !important;' + // Chrome, Safari
                            '-moz-animation:        none !important;' + // Firefox
                            '-ms-animation:         none !important;' + // IE
                            '-o-animation:          none !important;' + // Opera
                            'animation:             none !important;' + // CSS 3
                        '}';
                    Ext.util.CSS.createStyleSheet(turnOffTransitionsAndAnimationsCss);

                    // turn off jQuery-based animations
                    jQuery.fx.off = true;
                    jQuery.fn.bxSlider.defaults.useCSS = false;
                }
                else {
                    var ss = document.createElement('link');
                    ss.setAttribute('rel', 'stylesheet');
                    ss.setAttribute('type', 'text/css');
                    ss.setAttribute('href', './themes/a_default.theme/css/animations.css');
                    document.getElementsByTagName('head')[0].appendChild(ss);
                }
            })(Ozone, Ext, jQuery);
        </script>

        <link rel="stylesheet" type="text/css" href="./js-lib/jquery-ui-1.10.3/themes/base/jquery.ui.resizable.css">

        <script language="javascript">
            owfdojo.config.dojoBlankHtmlUrl =  './js-lib/dojo-1.5.0-windowname-only/dojo/resources/blank.html';
        </script>

        <!-- bring in custom header/footer resources -->
        <g:each in="${grailsApplication.mainContext.getBean('customHeaderFooterService').jsImportsAsList}" var="jsImport">
            <script type="text/javascript" src="${jsImport.encodeAsHTML()}"></script>
        </g:each>
        <g:each in="${grailsApplication.mainContext.getBean('customHeaderFooterService').cssImportsAsList}" var="cssImport">
            <link rel="stylesheet" href="${cssImport.encodeAsHTML()}" type="text/css" />
        </g:each>

        <!-- language switching -->
        <lang:preference lang="${params.lang}" />

        <!-- set Marketplace Version -->
        <marketplace:preference />

        <script type="text/javascript">

            // OWF-6032
            window.opener = null;

            // apply background image from app configuration
            if(Ozone.config.backgroundURL) {
                var css =   '#owf-body { ' +
                                'background-image: url("' + Ozone.config.backgroundURL + '") !important; ' +
                            '}';

                Ext.util.CSS.createStyleSheet(css);
            }

            function initLayoutComponents(customHeaderFooter, floatingWidgetManager,
                    bannerManager, dashboardDesignerManager, modalWindowManager, tooltipManager) {
                var layoutComponents = [];

                // create panel for custom header
                var showHeader = (customHeaderFooter.header != "" && customHeaderFooter.headerHeight > 0);
                var customHeader = {
                    id: 'customHeaderComponent',
                    xtype: 'component',
                    border: false,
                    frame: false,
                    hidden: !showHeader,
                    height: customHeaderFooter.headerHeight
                };

                // create panel for custom footer
                var showFooter = (customHeaderFooter.footer != "" && customHeaderFooter.footerHeight > 0);
                var customFooter = {
                    id: 'customFooterComponent',
                    xtype: 'component',
                    border: false,
                    frame: false,
                    hidden: !showFooter,
                    height: customHeaderFooter.footerHeight
                };


                // calculate height offset for main component
                var heightOffset = 0;

                if (showHeader) {
                    heightOffset = heightOffset - customHeaderFooter.headerHeight;
                }
                if (showFooter) {
                    heightOffset = heightOffset - customHeaderFooter.footerHeight;
                }

                // Build the layout components array.  Add functional panels as necessary.
                if (showHeader) {
                    customHeader.loader = {
                            url: customHeaderFooter.header,
                            autoLoad: true,
                            callback: Ozone.config.customHeaderFooter.onHeaderReady
                    }
                    layoutComponents.push(customHeader);
                }

                 // user's dashboards instances
                var dashboardStore = Ext.create('Ozone.data.DashboardStore', {
                    storeId: 'dashboardStore',
                    data: Ozone.initialData.dashboards
                });

                // user's widgets
                var widgetStore = Ext.create('Ozone.data.WidgetStore', {
                    storeId: 'widgetStore'
                });

                var widgets = Ozone.initialData.widgets;
                OWF.Collections = {};
                OWF.Collections.AppComponents = new Ozone.data.collections.Widgets({
                    results:  widgets.length,
                    rows: widgets
                }, {
                    parse: true
                });

                // mappings are not supported in Models,
                // they only supported through Ext Proxy Reader
                widgetStore.loadRecords(widgetStore.proxy.reader.read(Ozone.initialData.widgets).records);

                layoutComponents.push({
                    id: 'mainPanel',
                    itemId: 'mainPanel',
                    xtype: 'dashboardContainer',
                    autoHeight:true,
                    viewportId: 'viewport',
                    anchor: '100% ' + heightOffset,
                    dashboardStore: dashboardStore,
                    widgetStore: widgetStore,
                    appComponentsViewState: Ozone.initialData.appComponentsViewState,
                    floatingWidgetManager: floatingWidgetManager,
                    bannerManager: bannerManager,
                    dashboardDesignerManager: dashboardDesignerManager,
                    modalWindowManager: modalWindowManager,
                    tooltipManager: tooltipManager
                });

                if (showFooter) {
                    customFooter.loader = {
                        url: customHeaderFooter.footer,
                        autoLoad: true,
                        callback: Ozone.config.customHeaderFooter.onFooterReady
                    };
                    layoutComponents.push(customFooter);
                }
                return layoutComponents;
            }
        </script>
        <script type="text/javascript">

			// var logger = Ozone.log.getDefaultLogger();
			// var appender = logger.getEffectiveAppenders()[0];
			// appender.setThreshold(log4javascript.Level.INFO);
			// Ozone.log.setEnabled(true);

            var handleBodyOnScrollEvent = function(){
                document.body.scrollTop = 0;
                document.body.style.overflow = "hidden";
                document.body.scroll = "no";
                scroll(0,0);
                return;
            };

            if (Ext.isIE) {
                Ext.BLANK_IMAGE_URL = './themes/common/images/s.gif';
            }
            Ext.useShims = OWF.config.useShims;
            Ext.onReady(function() {

                Ozone.version = Ozone.version || {};
                Ozone.version.mpversion = Ozone.config.mpVersion || "2.5";

                //function to check if the login cookie
                //exists and if not, force a refresh
                //in order to force a re-login
                var testLoginCookie = function() {
                    var loggedIn = Ozone.config.loginCookieName == null ||
                        Ext.util.Cookies.get(Ozone.config.loginCookieName) != null;
                    if (!loggedIn) {
                        Ext.Msg.show({
                            buttons: Ext.Msg.OK,
                            msg: "You have been logged out.  Press OK to refresh the page and log back in.",
                            fn: function() {
                                location.reload(true);
                            }
                        });
                    }

                    return loggedIn;
                };

                //skip loading the rest of the page if the
                //login cookie is not found
                if (!testLoginCookie()) return;

                handleBodyOnScrollEvent();

                //Create the various z-index layers to be on top of the
                //base ZIndexManager, last created will be on top of others
                var floatingWidgetManager = new Ext.ZIndexManager(),
                    bannerManager = new Ext.ZIndexManager(),
                    dashboardDesignerManager = new Ext.ZIndexManager(),
                    modalWindowManager = new Ext.ZIndexManager(),
                    tooltipManager = new Ext.ZIndexManager();

                //init quicktips
                Ext.tip.QuickTipManager.init(true,{
                    xtype: 'ozonequicktip',
                    dismissDelay: 30000,
                    hideDelay: 500,
                    showDelay: 750,
                    zIndexManager: tooltipManager
                });

                Ext.History.init();

                // Use new shim for dd
                Ext.dd.DragDropMgr.useShim = true;

                var layoutComponents = initLayoutComponents(Ozone.config.customHeaderFooter,
                        floatingWidgetManager, bannerManager, dashboardDesignerManager,
                        modalWindowManager, tooltipManager);

                var continueProcessingPage = function() {

                    console.time('initload');

                    OWF.Mask = new Ozone.ux.AutoHideLoadMask(Ext.getBody(), {
                        msg:"Please wait...",
                        id: 'owf-body-mask'
                    });
                    OWF.Mask.show();

                    Ext.create('Ext.container.Viewport', {
                        id: 'viewport',
                        cls: 'viewport',
                        layout: {
                            type: 'fit'
                        },
                        items: [
                            {
                                xtype: 'container',
                                style: 'overflow:hidden',
                                layout: 'anchor',
                                items: layoutComponents
                            }
                        ]
                    });

                    setInterval(testLoginCookie, 5000);
              };

                if (Ozone.config.showAccessAlert &&
                        Ozone.config.showAccessAlert.toLowerCase() == "true") {
                    var accessAlertMsg = Ozone.config.accessAlertMsg;
                    var okButton = Ext.widget('button', {
                        id: 'accessAlertOKButton',
                        text: Ozone.layout.MessageBoxButtonText.ok,
                        scale: 'small',
                        minWidth: 50,
                        iconCls: 'accessAlertIcon',
                        handler: function() {
                            Ext.getCmp("accessAlertWin").close();
                            owfdojo.xhrPost({
                                url: Ozone.util.contextPath() + "/servlet/SessionServlet",
                                preventCache: true,
                                sync: true,
                                handleAs: "text",
                                content: {'key': 'showAccessAlert', 'value': 'false'},
                                load: function(response) {
                                    // added a timeout for better error handling
                                    // without this, any errors from continueProcessingPage method call are treated as Session errors
                                    setTimeout(continueProcessingPage, 0);
                                },
                                error: function(xhr, textStatus) {
                                    Ext.Msg.alert("Error", Ozone.util.ErrorMessageString.settingSessionDataMsg);
                                }
                            });
                        }
                    });
                    var alertWin = Ext.create('Ext.Window', {
                        id: "accessAlertWin",
                        title: "Warning",
                        html: "<p class='accessAlertMsgBody'>" + accessAlertMsg + "</p>",
                        cls: "accessAlert",
                        modal: false,
                        closable: false,
                        draggable: false,
                        height: 200,
                        width: 500,
                        autoScroll: true,
                        bbar: [{xtype: 'tbfill'},okButton,{xtype: 'tbfill'}]
                    });
                    alertWin.show(null, function() {
                        okButton.focus(false, true);
                        window.document.getElementById('accessAlertOKButton').focus();
                    });
                    //Ensure the shadow follows the window in IE
                    alertWin.on('resize', function() {
                        alertWin.syncShadow();
                    });
                }
                else {
                  continueProcessingPage();
                }
            });
        </script>
    </head>

     <body id="owf-body" onscroll="handleBodyOnScrollEvent();">
        <!-- Fields required for history management -->
        <form id="history-form" class="x-hidden">
            <input type="hidden" id="x-history-field" />
            <iframe id="x-history-frame" tabindex="-1"></iframe>
        </form>
    </body>
</html>
