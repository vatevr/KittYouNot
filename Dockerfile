# Собираем на основе образа с установленной Sbt
FROM entony/scala-mxnet-cuda-cudnn:2.12-1.3.1-9-7-builder AS builder

# Создаём необходимые каталоги и копируем данные
RUN mkdir /tmp/source /tmp/source/dependencies
COPY project /tmp/source/project
COPY src /tmp/source/src
COPY build.sbt /tmp/source/build.sbt

# Делаем ссылку на библиотеку MXNet, которая внутри образа и запускаем сборку
RUN ln -s /usr/local/share/mxnet/scala/linux-x86_64-gpu/mxnet-full_2.12-linux-x86_64-gpu-1.3.1-SNAPSHOT.jar /tmp/source/dependencies/mxnet-full_2.12-linux-x86_64-gpu-1.3.1-SNAPSHOT.jar && \
cd /tmp/source/ && sbt pack

# Создаём чистый образ с микросервисом
FROM entony/scala-mxnet-cuda-cudnn:2.12-1.3.1-9-7-runtime

# Добавляем в LD путь к Cuda библиотекам и Java
ENV LD_LIBRARY_PATH /usr/local/cuda-9.0/targets/x86_64-linux/lib/stubs:/usr/local/share/OpenCV/java

# Наша модель теперь будет лежать не в корне проекта а в /opt/app/models
ENV MODEL_PREFIX "/opt/app/models/resnet50_ssd_model"

# Создаём директория с приложением и копируем туда модель и собранный микросервис
RUN mkdir -p /opt/app
COPY --from=builder --chown=root:root /tmp/source/target/pack /opt/app
COPY models /opt/app/models

# Запускаем микросервис про старте контейнера
ENTRYPOINT /opt/app/bin/simple-predictor