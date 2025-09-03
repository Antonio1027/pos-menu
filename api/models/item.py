from django.db import models
from .menu import Menu

class Item(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    menu = models.ForeignKey(Menu, on_delete=models.CASCADE)

    def __str__(self):
        return self.name