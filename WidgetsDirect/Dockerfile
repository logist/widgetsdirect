FROM docker.iscinternal.com:5000/2018.1.0/isc-idp:2018.1.0.289.0
#FROM intersystems/isc-iris:gs2017
LABEL maintainer "sylvain.guilbaud@intersystems.com"
ARG ISC_PACKAGE_USER_PASSWORD
ARG ISC_PACKAGE_CSPSYSTEM_PASSWORD
ENV TMP_INSTALL_DIR="/tmp/install" \
 ISC_DATA_DIRECTORY="/data/docker/SYS/IDP2017" \
 InstallScript="install.scr" \
 InstallFile="Build.cls" \
 AppDir="CacheRESTStack" \
 AppName="widgetdirect" 
WORKDIR $TMP_INSTALL_DIR

COPY $AppDir $TMP_INSTALL_DIR/$AppDir

# Copy cache.key if present. Also copy Dockerfile so that it doesn't complain if there is no cache.key
COPY cache.key* Dockerfile $ISC_PACKAGE_INSTALLDIR/mgr/
COPY $InstallFile $TMP_INSTALL_DIR
RUN chmod -R a+rx $TMP_INSTALL_DIR && \
	echo _SYSTEM >$InstallScript && \
	echo $ISC_PACKAGE_USER_PASSWORD >>$InstallScript && \
	echo do \$system.OBJ.Load\(\"$TMP_INSTALL_DIR/$InstallFile\",\"ck\"\) >>$InstallScript && \
	echo do \#\#class\(gs17.Build\).Build\(\"$AppName\",\"$TMP_INSTALL_DIR/$AppDir\",\"/opt/$AppName\"\) >>$InstallScript && \
	echo zn \"$AppName\" >>$InstallScript && \
	echo do \#\#class\(Data.PopulateWidgets\).CreateWidgets\(\) >>$InstallScript && \
	echo do \#\#class\(Data.PopulateWidgets\).PopulateAccessories\(\) >>$InstallScript && \
	echo do \#\#class\(Data.PopulateWidgets\).PopulateLinks\(\) >>$InstallScript && \
	echo do \#\#class\(Data.PopulateWidgets\).CreateWWWidgets\(\) >>$InstallScript && \
	echo zn \"%SYS\" >>$InstallScript && \
	echo set a=\#\#class\(Security.Applications\).%OpenId\(\"/widgetsdirect/rest\"\) >>$InstallScript && \
	echo set a.DispatchClass=\"REST.Dispatch\" >>$InstallScript && \
	echo write a.%Save\(\) >>$InstallScript && \
	echo set ^installLog\(\$i\(^installLog\)\)=\$zdt\(\$h,3\) >>$InstallScript && \
	echo zwrite imported >>$InstallScript && \
	echo halt >>$InstallScript && \
	ccontrol start $ISC_PACKAGE_INSTANCENAME && \
	csession $ISC_PACKAGE_INSTANCENAME < $InstallScript && \
	ccontrol stop $ISC_PACKAGE_INSTANCENAME quietly && \
	mkdir /opt/$AppName/web && \
	cp -r $TMP_INSTALL_DIR/$AppDir/web/img /opt/$AppName/csp/. && \
 	rm -rf ${TMP_INSTALL_DIR}/* 
 	
EXPOSE 57772 1972 22 443 80
ENTRYPOINT ["/ccontainermain"]
