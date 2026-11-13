
## Docker image sizes

| Image | Size |
| --- | ---: |
| `jenkins-exam:dev` | 235 MB |
| `jenkins-exam:final` | 207 MB |

The final image is 28 MB smaller than the development image, a reduction of about 11.9%.
The development image includes pytest and its dependencies. The final image copies
the runtime environment from the builder stage and adds the application code.

[Docker image size output](evidence/images.txt)
