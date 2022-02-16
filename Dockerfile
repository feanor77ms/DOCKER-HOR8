#Imagen Docker Hornero
#by Paola Perez Dpto TI 2021

#INSTALACION DE SO VERSION ESTANDAR

FROM ubuntu:16.04

#CONSTANTES

  ENV GIT_BRANCH=8.0 \
  PYTHON_BIN=python \
  SERVICE_BIN=openerp-server

#DEFINO TZ

RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

#INSTALO DEPENDENCIAS

RUN apt update \
  && apt -yq install locales \
  && locale-gen es_EC.UTF-8 \
  && update-locale LC_ALL=es_EC.UTF-8 LANG=es_EC.UTF-8
  
ADD hor-dep/apt.txt /opt/hor-dep/apt.txt
RUN apt update \
  && awk '! /^ *(#|$)/' /opt/hor-dep/apt.txt | xargs -r apt install -yq
  
#RUN apt install coreutils

#CREO ODOO USER
RUN adduser --system --home=/opt/odoo/ --group odoo

#CREO DIR FACTURACION ELECTRONICA
ADD  hor-dir/make_dir.txt /opt/hor-dir/make_dir.txt
RUN /opt/hor-dir/make_dir.txt

#CREO DIRECTORIO DE INSTALACION HOR

RUN mkdir -p /opt/odoo \
    && chown -R odoo /opt/odoo
    
RUN mkdir -p /etc/odoo \
    && chown  odoo:odoo -R /etc/odoo
    
RUN mkdir -p /opt/odoo/log \
    && chown  odoo:odoo -R /opt/odoo/log    
    
USER odoo
   
#DESCARGO REPOHORNERO ULTIMA VERSION FUENTES
#agregar token para acceso a repositorio
ARG GITHUB_TOKEN=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
RUN git clone https://${GITHUB_TOKEN}@github.com/elhornero18/HORNERO-UIO-8.git /opt/odoo/HORNERO-UIO-8

#Cambiar a usuario root para instalar dependencias y dar permisos a los servicios
USER 0

#copiar lista de dependencias y extra dependencias
ADD hor-dep/pip.txt /opt/hor-dep/pip.txt
ADD hor-dep/requirements.txt /opt/hor-dep/requirements.txt

# Install LESS
RUN npm install -g less@2.7.3 less-plugin-clean-css@1.5.1 \
  && ln -s /usr/bin/nodejs /usr/bin/node

# Install wkhtmltopdf
ADD https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb \
  /opt/sources/wkhtmltox.deb
RUN dpkg -i /opt/sources/wkhtmltox.deb
RUN apt-get install -f
RUN ln -s /usr/local/bin/wkhtmltopdf /usr/bin
RUN ln -s /usr/local/bin/wkhtmltoimage /usr/bin

#INSTALAR DEPENDENCIAS PYTHON
#actualizar pip
RUN apt-get install openjdk-8-jdk -y
RUN pip install --upgrade pip==20.3

#INSTALO ODOO DEPENDENCIAS
RUN pip install -r /opt/hor-dep/requirements.txt

#INSTALO DEPENDENCIAS EXTRA
RUN pip install -r /opt/hor-dep/pip.txt

#COPY Y AUTOINICIO DE DEMONIO

COPY ./hor-dep/odoo-server8010 /etc/init.d
COPY ./hor-dep/odoo-server8011 /etc/init.d
COPY ./hor-dep/odoo-server8012 /etc/init.d
COPY ./hor-dep/odoo-server8069 /etc/init.d
COPY ./hor-dep/odoo-server8013 /etc/init.d
RUN  chmod 755 /etc/init.d/odoo-server8010
RUN  chmod 755 /etc/init.d/odoo-server8011
RUN  chmod 755 /etc/init.d/odoo-server8012
RUN  chmod 755 /etc/init.d/odoo-server8069
RUN  chmod 755 /etc/init.d/odoo-server8013
RUN chown root:root /etc/init.d/odoo-server8010
RUN chown root:root /etc/init.d/odoo-server8011
RUN chown root:root /etc/init.d/odoo-server8012
RUN chown root:root /etc/init.d/odoo-server8069
RUN chown root:root /etc/init.d/odoo-server8013

CMD chown odoo:odoo -R /etc/odoo && chown odoo:odoo -R /home/odoo && service odoo-server8010 start && service odoo-server8011 start && service odoo-server8012 start && service odoo-server8069 start && service odoo-server8013 start && tail -F /opt/odoo/log/odoo10.log

#EXPONGO PUERTOS

EXPOSE 8069 8010 8011 8012 8013


