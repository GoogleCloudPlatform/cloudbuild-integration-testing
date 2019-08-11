### get endpoint of deployed app 

get_nodeport() {
    kubectl get service cookieshop-web --kubeconfig=/workspace/kubeconfig --namespace=${STAGING_NAMESPACE} -o=jsonpath='{.spec.ports[0].nodePort}' 
}
get_nodeip() {
    kubectl get nodes --kubeconfig=/workspace/kubeconfig --output jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}'
}

until [ -n "$(get_nodeport)" ]; do
    echo "querying for nodeport"
    sleep 3
done

until [ -n "$(get_nodeip)" ]; do
    echo "querying for nodeip"
    sleep 3
done
echo "http://$(get_nodeip)/$(get_nodeport)" > /workspace/_app-url # save URL for use in next step