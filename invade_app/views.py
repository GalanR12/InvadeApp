from django.contrib.auth.decorators import login_required
from django.shortcuts import render
from .models import InvadeValue
from .forms import InvadeForm
from django.shortcuts import redirect


def index(request): 
    # Get all category objects
    invades = InvadeValue.objects.all()
    number_of_success_invades = InvadeValue.objects.filter(successfull="True").count()
    number_of_failed_invades = InvadeValue.objects.filter(not_successfull="True").count()
    number_of_draw_invades =  InvadeValue.objects.filter(draw="True").count()

    return render(request, 'home.html', context={
        'inv' : invades,
        'suc' : number_of_success_invades,
        'fail' : number_of_failed_invades,
        'draw' : number_of_draw_invades
    })

def add_invade(request):
    if request.method == "POST":
        form = InvadeForm(request.POST)
        if form.is_valid():
            inv_name = form.cleaned_data.get('name')
            inv_date = form.cleaned_data.get('date')
            inv_invade_status = request.POST['inlineRadioOptions']

            if inv_invade_status == "successfull":
                success = True
            else:
                success = False
            if inv_invade_status == "not_successfull":
                not_success = True
            else:
                not_success = False
            if inv_invade_status == "draw":
                i_draw = True
            else:
                i_draw = False

            invade = InvadeValue.objects.create(name=inv_name, date=inv_date, successfull = success, not_successfull = not_success, draw = i_draw)

        else:
            pass

    response = redirect('/')
    return response