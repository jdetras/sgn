package SGN::Controller::solGS::Correlation;

use Moose;
use namespace::autoclean;

use Cache::File;
use CXGN::Tools::Run;
use File::Temp qw / tempfile tempdir /;
use File::Spec::Functions qw / catfile catdir/;
use File::Slurp qw /write_file read_file/;
use File::Path qw / mkpath  /;
use File::Copy;
use File::Basename;

use JSON;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller' }


sub correlation_phenotype_data :Path('/correlation/phenotype/data/') Args(0) {
    my ($self, $c) = @_;
    
    my $pop_id = $c->req->param('population_id');
    $c->stash->{pop_id} = $pop_id;
  
    my $phenotype_dir  = catdir($c->config->{solgs_dir}, 'cache');
    my $phenotype_file = 'phenotype_data_' . $pop_id;
    $phenotype_file    = $c->controller('solGS::solGS')->grep_file($phenotype_dir, $phenotype_file);

    if ($phenotype_file) 
    {
        $self->create_correlation_dir($c);
        my $corre_dir  = $c->stash->{correlation_dir};
        my $corre_file = $c->controller('solGS::solGS')->grep_file($corre_dir, fileparse($phenotype_file));
        
        unless ($corre_file) 
        {
            copy($phenotype_file, $corre_dir);
        }
    }   
    else
    {      
        $self->create_correlation_phenodata_file($c);
        $phenotype_file =  $c->stash->{correlation_phenodata_file};
    }

    my $ret->{status} = 'failed';

    if($phenotype_file)
    {
        $ret->{status} = 'success';             
    }

    $ret = to_json($ret);
       
    $c->res->content_type('application/json');
    $c->res->body($ret);    

}


sub create_correlation_phenodata_file {
    my ($self, $c)  = @_;

    my $pop_id = $c->stash->{pop_id};

    $self->create_correlation_dir($c);
    my $corre_cache_dir = $c->stash->{correlation_dir};

    my $file_cache  = Cache::File->new(cache_root => $corre_cache_dir);
    $file_cache->purge();
                                       
    my $key = 'corr_phenotype_data_' . $pop_id;
    my $corre_pheno_file  = $file_cache->get($key);

    unless ($corre_pheno_file)
    {         
        $corre_pheno_file= catfile($corre_cache_dir, 'corr_phenotype_data_' . $pop_id);

        $self->get_phenotype_data($c);
        my $pheno_data =  $c->{correlation_pheno_data};

        write_file($corre_pheno_file, $pheno_data);
        $file_cache->set($key, $corre_pheno_file, '30 days');
    }

    $c->stash->{correlation_phenodata_file} = $corre_pheno_file;

}


sub get_phenotype_data {    
    my ($self, $c) = @_;
    
    my $pop_id = $c->stash->{pop_id};
    my $pheno_data = $c->model('solGS::solGS')->phenotype_data($c, $pop_id);
    my $formatted_pheno_data = $c->controller('solGS::solGS')->format_phenotype_dataset($c, $pheno_data);
  
    $c->{correlation_pheno_data} = $formatted_pheno_data;

}


sub create_correlation_dir {
    my ($self, $c) = @_;
    
    my $temp_dir        = $c->config->{cluster_shared_tempdir};
    my $cache_dir       = catdir($temp_dir, 'cache');
    my $correlation_dir = catdir($cache_dir, 'correlation'); 
   

    mkpath ([$temp_dir, $cache_dir, $correlation_dir], 0, 0755);
   
    $c->stash->{correlation_dir} = $correlation_dir;

}


sub correlation_output_file {
    my ($self, $c) = @_;
     
    my $pop_id = $c->stash->{pop_id};
    
    $self->create_correlation_dir($c);
    my $corre_dir = $c->stash->{correlation_dir};
    
    my $file_cache  = Cache::File->new(cache_root => $corre_dir);
    $file_cache->purge();
                                       
    my $key = 'corre_coefficients_' . $pop_id;
    my $corre_coefficients_file  = $file_cache->get($key);
   
    unless ($corre_coefficients_file)
    {         
        $corre_coefficients_file= catfile($corre_dir, "corre_coefficients_${pop_id}");

        write_file($corre_coefficients_file);
        $file_cache->set($key, $corre_coefficients_file, '30 days');
    }

    $c->stash->{corre_coefficients_file} = $corre_coefficients_file;

}


sub correlation_analysis_output :Path('/correlation/analysis/output') Args(0) {
    my ($self, $c) = @_;

    my $pop_id = $c->req->param('population_id');
    $c->stash->{pop_id} = $pop_id;

    $self->correlation_output_file($c);
    my $corre_coefficients_file = $c->stash->{corre_coefficients_file};
  
    if (!-s $corre_coefficients_file)
    {
        $self->run_correlation_analysis($c);
    
        $corre_coefficients_file = $c->stash->{corre_coefficients_file};
    }

    my $ret->{status} = 'failed';

    if (-s $corre_coefficients_file)
    {
        $ret->{status} = 'success';
        $ret->{data} = read_file('/data/prod/tmp/cache/correlation/correlation.json')
                
    }

    $ret = to_json($ret);
       
    $c->res->content_type('application/json');
    $c->res->body($ret);    

}


sub run_correlation_analysis {
    my ($self, $c) = @_;
    
    my $pop_id = $c->stash->{pop_id};
   
    $self->create_correlation_dir($c);
    my $corre_dir = $c->stash->{correlation_dir};
    
    my $pheno_file = 'phenotype_data_' . $pop_id;
    $pheno_file = $c->controller('solGS::solGS')->grep_file($corre_dir, $pheno_file);
 
    $self->correlation_output_file($c);
    my $corre_table_file = $c->stash->{corre_coefficients_file};

    if (-s $pheno_file) 
    {
        CXGN::Tools::Run->temp_base($corre_dir);
       
        my ( $corre_commands_temp, $corre_output_temp ) =
            map
        {
            my (undef, $filename ) =
                tempfile(
                    catfile(
                        CXGN::Tools::Run->temp_base(),
                        "corre_analysis_${pop_id}-$_-XXXXXX",
                         ),
                );
            $filename
        } qw / in out /;
    
    {
        my $corre_commands_file = $c->path_to('/R/correlation.r');
        copy( $corre_commands_file, $corre_commands_temp )
            or die "could not copy '$corre_commands_file' to '$corre_commands_temp'";
    }

      try 
      {
          print STDERR "\nsubmitting correlation job to the cluster..\n";
          my $r_process = CXGN::Tools::Run->run_cluster(
              'R', 'CMD', 'BATCH',
              '--slave',
              "--args $corre_table_file $pheno_file",
              $corre_commands_temp,
              $corre_output_temp,
              {
                  working_dir => $corre_dir,
                  max_cluster_jobs => 1_000_000_000,
              },
              );

          $r_process->wait;
          print STDERR "\ndone with correlation analysis..\n";
      }
      catch 
      {  
            
            my $err = $_;
            $err =~ s/\n at .+//s; #< remove any additional backtrace
            #     # try to append the R output
           
            try
            { 
                $err .= "\n=== R output ===\n".file($corre_output_temp)->slurp."\n=== end R output ===\n" 
            };
                     

            $c->throw(is_client_error   => 1,
                      title             => "Correlation analysis script error",
                      public_message    => "There is a problem running the correlation r script  on this dataset!",	     
                      notify            => 1, 
                      developer_message => $err,
            );
      };
        
    } 

    $c->stash->{corre_coefficients_file} = $corre_table_file;

}


sub begin : Private {
    my ($self, $c) = @_;

    $c->controller("solGS::solGS")->get_solgs_dirs($c);
  
}



####
1;
####